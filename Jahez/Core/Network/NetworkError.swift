//
//  NetworkError.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

import Foundation

// MARK: - Network Errors
public enum NetworkError: Error, Equatable {
    case expiredTokenMsg
    case badURL(_ error: String)
    case apiError(code: Int, error: String)
    case invalidJSON(_ error: String)
    case unauthorized(code: Int, error: String)
    case badRequest(code: Int, error: String)
    case serverError(code: Int, error: String)
    case noResponse(_ error: String)
    case unableToParseData(_ error: String)
    case unknown(code: Int, error: String)
    case noConnection
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badURL(let errorMsg):               return NSLocalizedString("Bad Url", comment: errorMsg)
        case .apiError(_, let errorMsg):          return errorMsg
        case .invalidJSON(let errorMsg):          return errorMsg
        case .unauthorized(_, let errorMsg):      return errorMsg
        case .badRequest(_, let errorMsg):        return errorMsg
        case .serverError(_, let errorMsg):       return errorMsg
        case .noResponse(let errorMsg):           return errorMsg
        case .unableToParseData(let errorMsg):    return errorMsg
        case .unknown(_, let errorMsg):           return errorMsg
        case .expiredTokenMsg:                    return "login_expired"
        case .noConnection:                       return "no_connection"
        }
    }
}

struct APIErrorResponse: Decodable {
    let status_message: String?
    let status_code: Int?
    let success: Bool?
}
