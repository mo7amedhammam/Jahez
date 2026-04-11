//
//  MoviesListModel.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

//DTO
struct MoviesResponseDTO: Decodable {
    let page: Int
    let results: [MovieDTO]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let popularity: Double
    let voteAverage: Double
    let voteCount: Int
    let genreIds: [Int]
    let originalLanguage: String
    let adult: Bool
    let video: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult, video
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
    }
}

struct Movie {
    let id: Int
    let title: String
    let posterURL: String?
    let backdropURL: String?
    let year: String
    let rating: Double
    let genreIds: [Int]
}

extension MovieDTO {
    func toDomain() -> Movie {
        let year = releaseDate?.prefix(4).description ?? "-"
        
        return Movie(
            id: id,
            title: title,
            posterURL: posterPath.map { AppConstants.imageBaseURL + $0 },
            backdropURL: backdropPath.map { AppConstants.imageBaseURL + $0 },
            year: year,
            rating: voteAverage,
            genreIds: genreIds
        )
    }
}
