//
//  APIClient.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import Alamofire
import Combine
import Foundation

class APIClient {

    static let shared = APIClient()
    var defaultQueryParams: [String: Any] {
        [
            "language": LanguageManager.current.rawValue
        ]
    }
    
    func request<T: Decodable>(
        _ type: T.Type,
        _ endpoint: APIEndpoint
    ) -> AnyPublisher<T, Error> {

        let url = endpoint.baseURL + endpoint.path
        let allParams = defaultQueryParams
            .merging(endpoint.parameters ?? [:]) { _, new in new }
        return AF.request(
            url,
            method: endpoint.method,
            parameters: allParams,
            encoding: URLEncoding.default,
            headers: endpoint.headers,
            requestModifier: { $0.timeoutInterval = 10 }
        )
        .validate(statusCode: 200..<300)
        .publishData()
        .tryMap { response in
            if let error = response.error {
                if error.isSessionTaskError {
                    throw NetworkError.noConnection
                }
            }

            guard let httpResponse = response.response else {
                throw NetworkError.noResponse("No HTTP response")
            }

            let statusCode = httpResponse.statusCode
            let data = response.data ?? Data()

            #if DEBUG
            if let request = response.request {
                print("➡️ [Request]: \(request)")
            }
            if let json = String(data: data, encoding: .utf8) {
                print("⬅️ [Response]: \(json)")
            }
            #endif

            if (200..<300).contains(statusCode) {
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw NetworkError.unableToParseData("Decoding failed: \(error.localizedDescription)")
                }
            }

            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
               let errorMessage = apiError.message {
                throw Self.networkError(
                    for: statusCode,
                    message: errorMessage
                )
            }

            if let error = response.error {
                throw Self.networkError(
                    for: statusCode,
                    message: error.localizedDescription
                )
            }

            throw Self.networkError(
                for: statusCode,
                message: "Unexpected server response"
            )
        }
        .retry(2)
        .eraseToAnyPublisher()
    }
}

private extension APIClient {
    static func networkError(for statusCode: Int, message: String) -> NetworkError {
        switch statusCode {
        case 400:
            return .badRequest(code: statusCode, error: message)
        case 401:
            return .unauthorized(code: statusCode, error: message)
        case 500...599:
            return .serverError(code: statusCode, error: message)
        default:
            return .apiError(code: statusCode, error: message)
        }
    }
}
