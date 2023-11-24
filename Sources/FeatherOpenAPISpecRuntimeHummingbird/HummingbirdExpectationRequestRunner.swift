//
//  File.swift
//
//
//  Created by Tibor Bodecs on 23/11/2023.
//

import OpenAPIRuntime
import HTTPTypes
import Hummingbird
import HummingbirdXCT
import FeatherOpenAPISpec

public struct HummingbirdExpectationRequestRunner: SpecRunner {

    let app: HBApplication

    public init(
        app: HBApplication
    ) {
        self.app = app
    }

    public func execute(
        req: HTTPRequest,
        body: HTTPBody
    ) async throws -> (
        response: HTTPResponse,
        body: HTTPBody
    ) {
        var reqBuffer = ByteBuffer()
        switch body.length {
        case .known(let value):
            try await body.collect(upTo: value, into: &reqBuffer)
        case .unknown:
            for try await chunk in body {
                reqBuffer.writeBytes(chunk)
            }
        }

        var result: (response: HTTPResponse, body: HTTPBody)!

        var uri = req.path ?? ""
        if !uri.hasPrefix("/") {
            uri = "/" + uri
        }
        try app.XCTExecute(
            uri: uri,
            method: .init(req.method),
            headers: .init(req.headerFields),
            body: reqBuffer,
            testCallback: { res in
                let response = HTTPResponse(
                    status: .init(
                        code: Int(res.status.code),
                        reasonPhrase: res.status.reasonPhrase
                    ),
                    headerFields: .init(res.headers)
                )
                let body = HTTPBody(.init(buffer: res.body ?? .init()))
                result = (response: response, body: body)
            }
        )
        return result
    }
}
