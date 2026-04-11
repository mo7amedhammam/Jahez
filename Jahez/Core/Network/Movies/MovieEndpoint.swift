//
//  MovieEndpoint.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

enum MoviesPaths: String {
    case genres = "/genre/movie/list"
    case discover = "/discover/movie"
    case details = "/movie/"
}
enum QueryKeys {
    static let page = "page"
    static let includeAdult = "include_adult"
    static let sortBy = "sort_by"
}
enum MovieSort: String {
    case popularityDesc = "popularity.desc"
    case releaseDateDesc = "release_date.desc"
    case voteAverageDesc = "vote_average.desc"
}

import Alamofire

enum MoviesEndpoint: APIEndpoint {
    
    case trending(
        page: Int,
        includeAdult: Bool = false,
        sortBy: MovieSort = .popularityDesc
    )
    
    case details(id: Int)
    case genres
}

extension MoviesEndpoint {
    
    var baseURL: String {
        AppConstants.baseURL
    }
    
    var path: String {
        switch self {
        case .trending:
            return MoviesPaths.discover.rawValue
            
        case .details(let id):
            return MoviesPaths.details.rawValue + "\(id)"
            
        case .genres:
            return MoviesPaths.genres.rawValue
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .trending, .details, .genres:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .trending(page, includeAdult, sortBy):
            return [
                QueryKeys.page: page,
                QueryKeys.includeAdult: includeAdult,
                QueryKeys.sortBy: sortBy.rawValue
            ]
            
        case .details, .genres:
            return nil
        }
    }
    
    var headers: HTTPHeaders {
        return [
            "Authorization": "Bearer \(APIConstants.bearerToken)"
        ]
    }
}
