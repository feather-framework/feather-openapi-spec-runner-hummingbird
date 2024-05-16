import Foundation
import Hummingbird

struct TestStruct: Codable {
    let title: String
}

extension TestStruct: ResponseCodable {}
