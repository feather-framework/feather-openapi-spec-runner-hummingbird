//
//  HummingbirdExpectationRequestRunner.swift
//  FeatherSpecHummingbird
//
//  Created by Tibor Bödecs on 24/11/2023.
//

import OpenAPIRuntime
import HTTPTypes
import Hummingbird
import HummingbirdTesting
import FeatherSpec

extension HTTPBody {
    /// Collects an HTTPBody into a `ByteBuffer`.
    ///
    /// - Returns: The collected `ByteBuffer`.
    func collect() async throws -> ByteBuffer {
        var buffer = ByteBuffer()
        switch length {
        case .known(let value):
            try await collect(upTo: Int(value), into: &buffer)
        case .unknown:
            for try await chunk in self {
                buffer.writeBytes(chunk)
            }
        }
        return buffer
    }
}

/// A custom spec runner for Hummingbird applications.
public struct HummingbirdExpectationRequestRunner: SpecRunner {

    /// The Hummingbird application.
    let app: any ApplicationProtocol

    /// The testing setup for the Hummingbird application.
    let testingSetup: TestingSetup

    /// Initializes a `HummingbirdExpectationRequestRunner` instance with the specified Hummingbird application and testing setup.
    ///
    /// - Parameters:
    ///   - app: The Hummingbird application to use for executing requests.
    ///   - testingSetup: The testing setup for the Hummingbird application.
    public init(
        app: any ApplicationProtocol,
        testingSetup: TestingSetup = .live
    ) {
        self.app = app
        self.testingSetup = testingSetup
    }

    /// Executes an HTTP request asynchronously against the Hummingbird application.
    ///
    /// - Parameters:
    ///   - req: The HTTP request to execute.
    ///   - body: The HTTP request body.
    /// - Returns: A tuple containing the HTTP response and response body.
    public func execute(
        req: HTTPRequest,
        body: HTTPBody
    ) async throws -> (
        response: HTTPResponse,
        body: HTTPBody
    ) {
        let buffer = try await body.collect()
        let uri = {
            var uri = req.path ?? ""
            if !uri.hasPrefix("/") {
                uri = "/" + uri
            }
            return uri
        }()

        return try await app.test(testingSetup) { client in
            try await client.execute(
                uri: uri,
                method: req.method,
                headers: req.headerFields,
                body: buffer,
                testCallback: { res in
                    let response = HTTPResponse(
                        status: .init(
                            code: res.status.code,
                            reasonPhrase: res.status.reasonPhrase
                        ),
                        headerFields: res.headers
                    )
                    let body = HTTPBody(.init(buffer: res.body))
                    return (response: response, body: body)
                }
            )
        }
    }
}
