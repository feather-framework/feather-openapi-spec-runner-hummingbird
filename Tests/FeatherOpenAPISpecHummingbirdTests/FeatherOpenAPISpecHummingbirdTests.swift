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
import Hummingbird
import HummingbirdTesting
@testable import FeatherOpenAPISpecHummingbird

enum SomeError: Error {
    case foo
}

struct Todo: Codable {
    let title: String
}

extension Todo: ResponseCodable {}

final class FeatherOpenAPISpecHummingbirdTests: XCTestCase {

    func other() async throws {
        throw SomeError.foo
    }

    func testHummingbird() async throws {
        let router = Router()
        router.post("todos") { req, ctx in
            try await req.decode(as: Todo.self, context: ctx)
        }

        let app = Application(router: router)
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
                let buffer = try await body.collect()
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
