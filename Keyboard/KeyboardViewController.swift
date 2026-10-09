import UIKit

@MainActor
final class KeyboardViewController: UIInputViewController {
    private let question = UITextView()
    private let result = UITextView()
    private let status = UILabel()
    private let ask = UIButton(type: .system)
    private let insert = UIButton(type: .system)
    private let copy = UIButton(type: .system)
    private let search = UISwitch()
    private var operation: Task<Void, Never>?
    private var service: any AnswerService = UnconfiguredService()
    var demoMode = false
    var demoInsert: ((String) -> Void)?
    private var latestAnswer: Answer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let stack = UIStackView(); stack.axis = .vertical; stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])
        view.heightAnchor.constraint(equalToConstant: 450).isActive = true
        question.isEditable = false; question.font = .preferredFont(forTextStyle: .body)
        question.backgroundColor = .secondarySystemBackground
        question.accessibilityLabel = "Question. Use selected text or Paste question to load it."
        question.heightAnchor.constraint(equalToConstant: 60).isActive = true
        result.isEditable = false; result.font = .preferredFont(forTextStyle: .body)
        result.accessibilityLabel = "AI answer"
        status.font = .preferredFont(forTextStyle: .caption1); status.numberOfLines = 2
        if demoMode { service = DemoService(); question.text = "Write a friendly Punjabi reply: I will call tomorrow." }
        status.text = "Only the question you review and submit is sent."
        let sourceRow = row([
            button("Setup", action: #selector(setup)),
            button("Selected text", action: #selector(loadSelected)),
            button("Paste question", action: #selector(pasteQuestion)),
            button("Clear", action: #selector(clearQuestion))
        ])
        let searchLabel = UILabel(); searchLabel.text = "Live search"; searchLabel.font = .preferredFont(forTextStyle: .caption1)
        let modeRow = UIStackView(arrangedSubviews: [searchLabel, search]); modeRow.spacing = 8
        ask.setTitle("Ask", for: .normal); ask.addTarget(self, action: #selector(send), for: .touchUpInside)
        let requestRow = row([modeRow, ask, button("Cancel", action: #selector(cancel))])
        insert.setTitle("Insert answer", for: .normal); insert.addTarget(self, action: #selector(insertAnswer), for: .touchUpInside)
        copy.setTitle("Copy", for: .normal); copy.addTarget(self, action: #selector(copyAnswer), for: .touchUpInside)
        insert.isEnabled = false; copy.isEnabled = false
        let footer = row([insert, copy, button("Next keyboard", action: #selector(nextKeyboard))])
        [sourceRow, question, requestRow, result, status].forEach(stack.addArrangedSubview)
        for letters in ["qwertyuiop", "asdfghjkl", "zxcvbnm"] {
            let keys = String(letters).map { char -> UIButton in
                let key = UIButton(type: .system); key.setTitle(String(char), for: .normal)
                key.addTarget(self, action: #selector(typeLetter(_:)), for: .touchUpInside)
                key.titleLabel?.font = .systemFont(ofSize: 17)
                return key
            }
            stack.addArrangedSubview(row(keys))
        }
        stack.addArrangedSubview(row([button("Space", action: #selector(typeSpace)), button("Delete", action: #selector(deleteLetter))]))
        stack.addArrangedSubview(footer)
    }
    private func button(_ title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system); button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        return button
    }
    private func row(_ views: [UIView]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: views); row.spacing = 6; row.distribution = .fillEqually; return row
    }
    @objc private func typeLetter(_ sender: UIButton) {
        guard operation == nil else { return }
        question.text += sender.currentTitle ?? ""
    }
    @objc private func typeSpace() { if operation == nil { question.text += " " } }
    @objc private func deleteLetter() { if operation == nil && !question.text.isEmpty { question.text.removeLast() } }
    @objc private func loadSelected() {
        guard operation == nil else { return }
        question.text = textDocumentProxy.selectedText ?? ""
        status.text = question.text.isEmpty ? "Select your question in the app, then tap Selected text." : "Review the question, then tap Ask."
    }
    @objc private func pasteQuestion() {
        guard hasFullAccess || demoMode else { status.text = KeyboardFailure.noFullAccess.localizedDescription; return }
        guard operation == nil else { return }
        question.text = String((UIPasteboard.general.string ?? "").prefix(4000))
        status.text = "Review pasted text before sending. Do not send secrets."
    }
    @objc private func clearQuestion() { cancel(); question.text = ""; result.text = ""; latestAnswer = nil; insert.isEnabled = false; copy.isEnabled = false }
    @objc private func send() {
        guard operation == nil else { return }
        guard hasFullAccess || demoMode else { status.text = KeyboardFailure.noFullAccess.localizedDescription; return }
        let prompt = question.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { status.text = "Add a question first."; return }
        if !demoMode {
            service = ProviderService(configuration: .init(accountID: KeyStore.read("account"), cloudflareToken: KeyStore.read("cloudflare"), tavilyKey: KeyStore.read("tavily"), freePlanConfirmed: KeyStore.read("free") == "yes"))
        }
        latestAnswer = nil; insert.isEnabled = false; copy.isEnabled = false; ask.isEnabled = false
        status.text = "Asking..."; let live = search.isOn
        operation = Task { [weak self] in
            guard let self else { return }
            defer { self.operation = nil; self.ask.isEnabled = true }
            do {
                let answer = try await self.service.answer(question: prompt, liveSearch: live)
                try Task.checkCancellation()
                self.latestAnswer = answer; self.result.text = answer.text
                self.status.text = answer.searched ? "Live search used. Review the sources and answer." : "Model answer, not a live web search. Check important facts."
                self.insert.isEnabled = !answer.text.isEmpty; self.copy.isEnabled = !answer.text.isEmpty
            } catch is CancellationError { self.status.text = "Cancelled." }
            catch { self.status.text = error.localizedDescription }
        }
    }
    @objc private func cancel() { operation?.cancel() }
    @objc private func insertAnswer() {
        guard let answer = latestAnswer else { return }
        if demoMode { demoInsert?(answer.text) } else { textDocumentProxy.insertText(answer.text) }; status.text = "Inserted into the current text field. Review before sending."
    }
    @objc private func copyAnswer() {
        guard hasFullAccess, let answer = latestAnswer else { return }
        UIPasteboard.general.setItems([[UIPasteboard.typeAutomatic: answer.text]], options: [.localOnly: true, .expirationDate: Date().addingTimeInterval(300)])
        status.text = "Copied locally for 5 minutes."
    }
    func runDemoAsk() { send() }
    func runDemoInsert() { insertAnswer() }
    @objc private func setup() {
        let alert = UIAlertController(title: "Private key setup", message: "Only use Workers Free and Tavily Researcher with pay-as-you-go OFF. Keys stay in this extension's Keychain, not shared with the container app.", preferredStyle: .alert)
        for label in ["Cloudflare account ID", "Workers AI token", "Tavily API key"] {
            alert.addTextField { field in field.placeholder = label; field.isSecureTextEntry = label != "Cloudflare account ID"; field.autocorrectionType = .no; field.autocapitalizationType = .none }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save: I verified free plans", style: .default) { [weak self] _ in
            guard let fields = alert.textFields, fields.count == 3 else { return }
            do {
                for (index, name) in ["account", "cloudflare", "tavily"].enumerated() { try KeyStore.save(fields[index].text ?? "", name: name) }
                try KeyStore.save("yes", name: "free")
                self?.status.text = "Saved privately. Only reviewed questions are sent."
            } catch { self?.status.text = "Key storage failed. Nothing is configured." }
        })
        present(alert, animated: true)
    }
    @objc private func nextKeyboard() { advanceToNextInputMode() }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); cancel() }
}
