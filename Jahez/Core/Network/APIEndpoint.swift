//
//  APIEndpoint.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//


import Alamofire

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders { get }
}