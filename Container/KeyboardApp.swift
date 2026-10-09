import SwiftUI

@main
struct KeyboardApp: App {
    var body: some Scene { WindowGroup { if ProcessInfo.processInfo.arguments.contains("-keyboard-demo") { DemoView() } else { SetupView() } } }
}
struct SetupView: View {
    @State private var sample = "Write a short friendly reply in Punjabi: I will call you tomorrow."
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal AI Keyboard") {
                    Text("Ask from a text field, review the answer, then insert it. No messages are sent automatically.")
                    Text("Setup is not connected to a live provider yet.").foregroundStyle(.orange)
                }
                Section("Enable after signing") {
                    Text("1. Sign the app AND its embedded keyboard extension in ESign/Feather. Extension installation has not been tested on your phone.")
                    Text("2. Settings → General → Keyboard → Keyboards → Add New Keyboard → AI Keyboard.")
                    Text("3. Enable Allow Full Access only when you want network questions. Only your reviewed question is sent.")
                    Text("4. In a supported app, hold the globe key and choose AI Keyboard.")
                }
                Section("Try a question") {
                    TextEditor(text: $sample).frame(minHeight: 110)
                    Text("Type here with your usual keyboard in any language. Select the question or copy it, switch to AI Keyboard, then tap Selected text or Paste question. Ask, review, then Insert answer.").font(.footnote)
                }
                Section("Limits") {
                    Text("Password and phone-pad fields use Apple's keyboard. Some apps block custom keyboards. This v1 does not add a Punjabi key layout, dictation or autocorrect.")
                    Text("Live-search citations will be shown only after an actual search. Free quotas can run out; there is no paid fallback.")
                }
            }.navigationTitle("AI Keyboard")
        }
    }
}

struct DemoView: View {
    @State private var inserted = "Answer inserts here after you review it."
    var body: some View {
        VStack(spacing: 12) {
            Text("AI Keyboard - UI DEMO").font(.title2.bold())
            Text("Simulated host field · fixture answer, NOT live AI/search").font(.caption).foregroundStyle(.orange)
            Text(inserted).frame(maxWidth: .infinity, minHeight: 100).padding().background(Color.secondary.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))
            KeyboardPreview(inserted: $inserted).frame(height: 380)
            Text("Preview uses the keyboard's actual UI/controller. System enablement, ESign signing and live services still need testing.").font(.caption).foregroundStyle(.secondary)
        }.padding()
    }
}
struct KeyboardPreview: UIViewControllerRepresentable {
    @Binding var inserted: String
    func makeUIViewController(context: Context) -> KeyboardViewController {
        let controller = KeyboardViewController(); controller.demoMode = true
        controller.demoInsert = { text in inserted = text }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3)); controller.runDemoAsk()
            try? await Task.sleep(for: .seconds(5)); controller.runDemoInsert()
        }
        return controller
    }
    func updateUIViewController(_ controller: KeyboardViewController, context: Context) {}
}
