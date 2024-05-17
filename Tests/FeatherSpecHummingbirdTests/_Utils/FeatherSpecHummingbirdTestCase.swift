import XCTest
import FeatherSpec
import Hummingbird
import HummingbirdTesting
@testable import FeatherSpecHummingbird

class FeatherSpecHummingbirdTestCase: XCTestCase {

    var runner: SpecRunner!

    override func setUp() async throws {

        let router = Router()

        router.post("getSameObjectBack") { req, ctx in
            try await req.decode(as: TestStruct.self, context: ctx)
        }

        router.put("putObject") { req, ctx in
            TestStruct(title: "updatedTitle")
        }

        router.patch("patchObject") { req, ctx in
            TestStruct(title: "patchedTitle")
        }

        router.get("getOk") { req, ctx in
            HTTPResponse.Status.ok
        }

        router.get("getBadRequest") { req, ctx in
            HTTPResponse.Status.badRequest
        }

        router.patch("patchInternalServerError") { req, ctx in
            HTTPResponse.Status.internalServerError
        }

        let app = Application(router: router)
        runner = HummingbirdExpectationRequestRunner(app: app)
    }

}
