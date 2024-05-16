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

/// a Hummingbird based spec runner
public struct HummingbirdExpectationRequestRunner: SpecRunner {

    let app: any ApplicationProtocol
    let testingSetup: TestingSetup

    /// initializes a new spec runner using an application protocol
    public init(
        app: any ApplicationProtocol,
        testingSetup: TestingSetup = .live
    ) {
        self.app = app
        self.testingSetup = testingSetup
    }

    /// Execute a request
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
