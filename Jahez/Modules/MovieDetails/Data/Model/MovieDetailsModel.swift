//
//  MovieDetailsModel.swift
//  Jahez
//
//  Created by mohamed hammam on 10/04/2026.
//

//DTO
struct MovieDetailsDTO: Decodable {
    let id: Int
    let title: String
    let overview: String?
    let runtime: Int?
    let releaseDate: String?
    let genres: [GenreDTO]?
    let homepage: String?
    let budget: Int?
    let revenue: Int?
    let status: String?
    let tagline: String?
    let posterPath: String?
    let backdropPath: String?
    
    let productionCompanies: [ProductionCompanyDTO]?
    let spokenLanguages: [SpokenLanguageDTO]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, homepage, budget, revenue, status, tagline
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case productionCompanies = "production_companies"
        case spokenLanguages = "spoken_languages"
    }
}

//Domain --> Model
struct MovieDetails: Codable {
    let id: Int
    let title: String
    let overview: String
    let runtime: Int
    let releaseDate: String
    let genres: [Genre]
    let posterPath: String?
    let backdropPath: String?
    let status: String
    let tagline: String
    let homepage: String
    let budget: Int
    let revenue: Int
    let languages: [String]
}

extension MovieDetailsDTO {
    func toDomain() -> MovieDetails {
        MovieDetails(
            id: id,
            title: title,
            overview: overview ?? "",
            runtime: runtime ?? 0,
            releaseDate: releaseDate ?? "",
            genres: genres?.map { $0.toDomain() } ?? [],
            posterPath: posterPath.map { AppConstants.imageBaseURL + $0 },
            backdropPath: backdropPath.map { AppConstants.imageBaseURL + $0 },
            status: status ?? "",
            tagline: tagline ?? "",
            homepage: homepage ?? "",
            budget: budget ?? 0,
            revenue: revenue ?? 0,
            languages: spokenLanguages?.map(\.englishName) ?? []
        )
    }
}
