import XCTest
import OpenAPIRuntime
import FeatherSpec
import Hummingbird
@testable import FeatherSpecHummingbird

final class FeatherSpecHummingbirdTests: XCTestCase {

    let todo = Todo(title: "task01")
    let body = Todo(title: "task01").httpBody
    
    func todosApp() async throws -> any ApplicationProtocol {
        let router = Router()
        router.post("todos") { req, ctx in
            try await req.decode(as: Todo.self, context: ctx)
        }

        return Application(router: router)
    }
    
    func testMutatingfuncSpec() async throws {
        let app = try await todosApp()
        let runner = HummingbirdSpecRunner(app: app)
        
        var spec = Spec()
        spec.setMethod(.post)
        spec.setPath("todos")
        spec.setBody(todo.httpBody)
        spec.setHeader(.contentType, "application/json")
        spec.addExpectation(.ok)
        spec.addExpectation { response, body in
            let todo = try await body.decode(Todo.self, with: response)
            XCTAssertEqual(todo.title, self.todo.title)
        }
        
        try await runner.run(spec)
    }
    
    func testBuilderFuncSpec() async throws {
        let app = try await todosApp()
        let runner = HummingbirdSpecRunner(app: app)
        
        let spec = Spec()
            .post("todos")
            .header(.contentType, "application/json")
            .body(body)
            .expect(.ok)
            .expect { response, body in
                let todo = try await body.decode(Todo.self, with: response)
                XCTAssertEqual(todo.title, "task01")
            }
        
        try await runner.run(spec)
    }
    
    func testDslSpec() async throws {
        let app = try await todosApp()
        let runner = HummingbirdSpecRunner(app: app)
        
        let spec = SpecBuilder {
            Method(.post)
            Path("todos")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, body in
                let todo = try await body.decode(Todo.self, with: response)
                XCTAssertEqual(todo.title, "task01")
            }
        }
        .build()
        
        try await runner.run(spec)
    }
    
    func testMultipleSpecs() async throws {
        let app = try await todosApp()
        let runner = HummingbirdSpecRunner(app: app)
        
        let spec1 = SpecBuilder {
            Method(.post)
            Path("todos")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
        }
        .build()
        
        let spec2 = SpecBuilder {
            Method(.post)
            Path("/todos")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
        }
        .build()
        
        try await runner.run(spec1, spec2)
    }
    
    func testNoPath() async throws {
        let router = Router()
        let app = Application(router: router)
        let runner = HummingbirdSpecRunner(app: app)
        
        try await runner.run {
            Method(.get)
        }
    }
    
    func testUnkownLength() async throws {
        let sequence = AnySequence(#"{"title":"task01"}"#.utf8)
        let body = HTTPBody(
            sequence,
            length: .unknown,
            iterationBehavior: .single
        )
        
        let app = try await todosApp()
        let runner = HummingbirdSpecRunner(app: app)
        
        try await runner.run {
            Method(.post)
            Path("todos")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, body in
                let todo = try await body.decode(Todo.self, with: response)
                XCTAssertEqual(todo.title, "task01")
            }
        }
    }
}
