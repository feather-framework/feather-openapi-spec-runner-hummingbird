import OpenAPIRuntime
import HTTPTypes
import Hummingbird
import HummingbirdTesting
import FeatherSpec

/// A struct that conforms to the `SpecExecutor` protocol and executes HTTP requests.
///
/// This executor uses a `TestClientProtocol` to perform the actual HTTP request execution and handles
/// the response and body transformations.
struct HummingbirdSpecExecutor: SpecExecutor {

    /// The client responsible for executing HTTP requests.
    let client: TestClientProtocol

    /// Executes an HTTP request with the provided request and body.
    ///
    /// This function collects the body data, constructs the request URI, and uses the client to execute the request.
    /// It transforms the client response into an `HTTPResponse` and `HTTPBody`.
    ///
    /// - Parameters:
    ///   - req: The HTTP request to be executed.
    ///   - body: The body of the HTTP request.
    ///
    /// - Returns: A tuple containing the HTTP response and the response body.
    ///
    /// - Throws: Rethrows an underlying error.
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

        return try await client.execute(
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
