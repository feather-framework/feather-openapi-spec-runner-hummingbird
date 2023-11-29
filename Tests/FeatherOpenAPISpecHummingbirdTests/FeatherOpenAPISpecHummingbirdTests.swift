//
//  FeatherOpenAPISpecHummingbirdTests.swift
//  FeatherOpenAPISpecHummingbird
//
//  Created by Tibor Bödecs on 24/11/2023.
//

import Foundation
import XCTest
import OpenAPIRuntime
import HTTPTypes
import FeatherOpenAPISpec
import FeatherOpenAPISpecHummingbird
import Hummingbird
import HummingbirdFoundation
import HummingbirdXCT

enum SomeError: Error {
    case foo
}

struct Todo: Codable {
    let title: String
}

extension Todo: HBResponseCodable {}

final class FeatherOpenAPISpecHummingbirdTests: XCTestCase {

    func other() async throws {
        throw SomeError.foo
    }

    func testHummingbird() async throws {
        let app = HBApplication(testing: .embedded)
        app.encoder = JSONEncoder()
        app.decoder = JSONDecoder()
        app.router.post("todos") { req in try req.decode(as: Todo.self) }

        try app.XCTStart()
        defer { app.XCTStop() }

        let runner = HummingbirdExpectationRequestRunner(app: app)
        try await test(using: runner)
    }

    func test(using runner: SpecRunner) async throws {
        let encoder = JSONEncoder()
        var buffer = ByteBuffer()
        try encoder.encode(Todo(title: "task01"), into: &buffer)
        let body = HTTPBody(.init(buffer: buffer))

        try await SpecBuilder {
            Method(.post)
            Path("todos")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, body in
                var buffer = ByteBuffer()
                switch body.length {
                case .known(let value):
                    try await body.collect(upTo: Int(value), into: &buffer)
                case .unknown:
                    for try await chunk in body {
                        buffer.writeBytes(chunk)
                    }
                }
                let decoder = JSONDecoder()
                let todo = try decoder.decode(Todo.self, from: buffer)
                XCTAssertEqual(todo.title, "task01")
            }
        }
        .build(using: runner)
        .test()

        var spec = Spec(runner: runner)
        spec.setMethod(.post)
        spec.setPath("todos")
        spec.setBody(body)
        spec.setHeader(.contentType, "application/json")
        spec.addExpectation(.ok)
        spec.addExpectation { response, body in
            /// same as above...
        }
        try await spec.test()

        try await Spec(runner: runner)
            .post("todos")
            .header(.contentType, "application/json")
            .body(body)
            .expect(.ok)
            .expect { response, body in
                // some expectation...
            }
            .test()
    }

}
