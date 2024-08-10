import OpenAPIRuntime
import HTTPTypes
import Hummingbird
import HummingbirdTesting
import FeatherSpec

/// A struct that conforms to the `SpecRunner` protocol and runs specifications.
///
/// This runner initializes with an application and a testing setup, and uses the application to perform tests
/// with a provided block that takes a `SpecExecutor`.
public struct HummingbirdSpecRunner: SpecRunner {

    /// The application that conforms to `ApplicationProtocol`.
    private let app: any ApplicationProtocol
    
    /// The setup configuration for testing.
    private let testingSetup: TestingSetup

    /// Initializes a new instance of `HummingbirdSpecRunner`.
    ///
    /// - Parameters:
    ///   - app: An application conforming to `ApplicationProtocol`.
    ///   - testingSetup: The setup configuration for testing. Defaults to `.live`.
    public init(
        app: any ApplicationProtocol,
        testingSetup: TestingSetup = .live
    ) {
        self.app = app
        self.testingSetup = testingSetup
    }

    /// Runs a test with the provided block.
    ///
    /// This function uses the application to perform a test with the given setup. It passes a `HummingbirdSpecExecutor`
    /// to the block, which is used to execute HTTP requests within the test.
    ///
    /// - Parameter block: A closure that takes a `SpecExecutor` and performs asynchronous operations.
    ///
    public func test(
        block: @escaping (SpecExecutor) async throws -> Void
    ) async throws {
        try await app.test(testingSetup) { client in
            try await block(HummingbirdSpecExecutor(client: client))
        }
    }
}
