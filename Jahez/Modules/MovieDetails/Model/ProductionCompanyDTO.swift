//
//  ProductionCompanyDTO.swift
//  Jahez
//
//  Created by mohamed hammam on 11/04/2026.
//


struct ProductionCompanyDTO: Decodable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}
struct SpokenLanguageDTO: Decodable {
    let englishName: String
    let iso6391: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case englishName = "english_name"
        case iso6391 = "iso_639_1"
    }
}