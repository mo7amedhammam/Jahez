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
    
    func request<T: Decodable>(
        _ type: T.Type,
        _ endpoint: APIEndpoint
    ) -> AnyPublisher<T, Error> {
        
        let url = endpoint.baseURL + endpoint.path
        
        return AF.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: URLEncoding.default,
            headers: endpoint.headers,
            requestModifier: { $0.timeoutInterval = 30 }
        )
        .validate(statusCode: 200..<300)
        .publishData()
        .tryMap { response in
            
            // Validate HTTP response
            guard let httpResponse = response.response else {
                throw NetworkError.invalidJSON("No HTTP response")
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
            
            // Handle no internet
            if let error = response.error {
                if error.isSessionTaskError {
                    throw NetworkError.noConnection
                } else {
                    throw NetworkError.serverError(code: statusCode, error: error.localizedDescription)
                }
            }
            
            // Decode success response
            if (200..<300).contains(statusCode) {
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw NetworkError.unableToParseData("Decoding failed: \(error.localizedDescription)")
                }
            }
            
            // Decode API error response
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw NetworkError.apiError(
                    code: apiError.status_code ?? statusCode,
                    error: apiError.status_message ?? "Unknown API error"
                )
            }
            
            // Fallback error
            throw NetworkError.serverError(code: statusCode, error: "Unexpected server response")
        }
        .retry(2)
        .eraseToAnyPublisher()
    }
}
