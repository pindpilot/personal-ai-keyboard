import Foundation

struct SearchSource: Codable, Equatable, Sendable {
    let title: String
    let url: URL
    let excerpt: String
}
struct Answer: Sendable {
    let text: String
    let sources: [SearchSource]
    let searched: Bool
}
enum KeyboardFailure: Error, LocalizedError {
    case noFullAccess, missingConfiguration, freePlanNotConfirmed, quota, rejected, network, malformed
    var errorDescription: String? {
        switch self {
        case .noFullAccess: "Enable Allow Full Access in iPhone Settings to ask AI."
        case .missingConfiguration: "Set up your provider keys in the keyboard's private setup panel."
        case .freePlanNotConfirmed: "Confirm a free, non-metered account before sending."
        case .quota: "Free limit reached. No paid fallback or automatic retries."
        case .rejected: "The service rejected this question. No rerouting."
        case .network: "Could not connect. Nothing was inserted."
        case .malformed: "No usable answer returned."
        }
    }
}
protocol AnswerService: Sendable {
    func answer(question: String, liveSearch: Bool) async throws -> Answer
}
/// Placeholder gate, not a fake AI response. Replaced only after provider approval.
struct UnconfiguredService: AnswerService {
    func answer(question: String, liveSearch: Bool) async throws -> Answer {
        throw KeyboardFailure.missingConfiguration
    }
}
