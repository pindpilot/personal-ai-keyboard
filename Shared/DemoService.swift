import Foundation

/// Only for an explicit UI preview, never selected in a live-provider build.
struct DemoService: AnswerService {
    func answer(question: String, liveSearch: Bool) async throws -> Answer {
        try await Task.sleep(for: .milliseconds(700))
        return Answer(text: "Main tuhanu kal phone karanga.\n\n[DEMO ANSWER - not live AI or web search]", sources: [], searched: false)
    }
}
