//
//  FeatherSpecHummingbirdTests.swift
//  FeatherSpecHummingbird
//
//  Created by Tibor Bödecs on 24/11/2023.
//

import Foundation
import XCTest
import OpenAPIRuntime
import HTTPTypes
import FeatherSpec
import Hummingbird
import HummingbirdTesting
@testable import FeatherSpecHummingbird

final class FeatherSpecHummingbirdTests: FeatherSpecHummingbirdTestCase {

    func testGetWithSpecBuilder() async throws {
        let body = try await getTestBody()
        try await SpecBuilder {
            Method(.post)
            Path("getSameObjectBack")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, body in
                let testStruct = try await self.checkResponse(body)
                XCTAssertEqual(testStruct.title, "task01")
            }
        }
        .build(using: runner)
        .test()
    }

    func testGetWithSpec() async throws {
        let body = try await getTestBody()
        var spec = Spec(runner: runner)
        spec.setMethod(.post)
        spec.setPath("getSameObjectBack")
        spec.setBody(body)
        spec.setHeader(.contentType, "application/json")
        spec.addExpectation(.ok)
        spec.addExpectation { response, body in
            let testStruct = try await self.checkResponse(body)
            XCTAssertEqual(testStruct.title, "task01")
        }
        try await spec.test()
    }

    func testGetWithSpec2() async throws {
        let body = try await getTestBody()
        try await Spec(runner: runner)
            .post("getSameObjectBack")
            .header(.contentType, "application/json")
            .body(body)
            .expect(.ok)
            .expect { response, body in
                let testStruct = try await self.checkResponse(body)
                XCTAssertEqual(testStruct.title, "task01")
            }
            .test()
    }

    func testPut() async throws {
        let body = try await getTestBody()
        try await Spec(runner: runner)
            .put("putObject")
            .header(.contentType, "application/json")
            .body(body)
            .expect(.ok)
            .expect { response, body in
                let testStruct = try await self.checkResponse(body)
                XCTAssertEqual(testStruct.title, "updatedTitle")
            }
            .test()
    }

    func testPatch() async throws {
        let body = try await getTestBody()
        try await Spec(runner: runner)
            .patch("patchObject")
            .header(.contentType, "application/json")
            .body(body)
            .expect(.ok)
            .expect { response, body in
                let testStruct = try await self.checkResponse(body)
                XCTAssertEqual(testStruct.title, "patchedTitle")
            }
            .test()
    }

    func testGetOK() async throws {
        try await Spec(runner: runner)
            .get("getOk")
            .expect(.ok)
            .test()
    }

    func testGetBadRequest() async throws {
        try await Spec(runner: runner)
            .get("getBadRequest")
            .expect(.badRequest)
            .test()
    }

    func testPatchInternalServerError() async throws {
        try await Spec(runner: runner)
            .patch("patchInternalServerError")
            .expect(.internalServerError)
            .test()
    }

    func testNotFound() async throws {
        try await Spec(runner: runner)
            .head("notAddedToTheRouter")
            .expect(.notFound)
            .test()
    }

    private func getTestBody() async throws -> HTTPBody {
        let encoder = JSONEncoder()
        var buffer = ByteBuffer()
        try encoder.encode(TestStruct(title: "task01"), into: &buffer)
        return HTTPBody(.init(buffer: buffer))
    }

    private func checkResponse(_ body: HTTPBody) async throws -> TestStruct {
        let buffer = try await body.collect()
        let decoder = JSONDecoder()
        return try decoder.decode(TestStruct.self, from: buffer)
    }

}
