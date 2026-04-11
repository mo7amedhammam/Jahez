//
//  GenreDTO.swift
//  Jahez
//
//  Created by mohamed hammam on 11/04/2026.
//

//Genre
struct GenreDTO: Decodable {
    let id: Int
    let name: String
}
struct Genre {
    let id: Int
    let name: String
}

extension GenreDTO {
    func toDomain() -> Genre {
        Genre(id: id, name: name)
    }
}
