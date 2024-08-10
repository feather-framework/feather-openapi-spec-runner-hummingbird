import OpenAPIRuntime
import HTTPTypes
import Foundation

extension HTTPBody {

    func decode<T>(
        _ type: T.Type,
        with response: HTTPResponse
    ) async throws -> T where T: Decodable {
        let length = Int(response.headerFields[.contentLength]!)!
        let data = try await Data(collecting: self, upTo: Int(length))
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
