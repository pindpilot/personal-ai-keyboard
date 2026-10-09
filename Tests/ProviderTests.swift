import XCTest
@testable import PersonalAIKeyboard
final class ProviderTests: XCTestCase {
    func testUnconfiguredNeverFabricatesAnswer() async {
        do { _ = try await UnconfiguredService().answer(question: "Hello", liveSearch: true); XCTFail("Must reject") }
        catch { XCTAssertTrue(error is KeyboardFailure) }
    }
    func testPaidGateRejectsBeforeNetwork() async {
        let service = ProviderService(configuration: .init(accountID: String(repeating: "a", count: 32), cloudflareToken: "fixture", tavilyKey: "fixture", freePlanConfirmed: false))
        do { _ = try await service.answer(question: "Hello", liveSearch: true); XCTFail("Must reject") }
        catch { XCTAssertEqual(error.localizedDescription, KeyboardFailure.freePlanNotConfirmed.localizedDescription) }
    }
    func testInvalidAccountRejectsBeforeNetwork() async {
        let service = ProviderService(configuration: .init(accountID: "invalid", cloudflareToken: "fixture", tavilyKey: "fixture", freePlanConfirmed: true))
        do { _ = try await service.answer(question: "Hello", liveSearch: false); XCTFail("Must reject") }
        catch { XCTAssertEqual(error.localizedDescription, KeyboardFailure.missingConfiguration.localizedDescription) }
    }
    func testDemoIsClearlyLabelledAndNotSearched() async throws {
        let answer = try await DemoService().answer(question: "Hello", liveSearch: true)
        XCTAssertTrue(answer.text.contains("DEMO ANSWER")); XCTAssertFalse(answer.searched); XCTAssertTrue(answer.sources.isEmpty)
    }
}
