//
//  CacheStoreTests.swift
//  JahezTests
//
//  Created by Codex on 12/04/2026.
//

import Foundation
import RealmSwift
import Testing
@testable import Jahez

struct CacheStoreTests {

    @Test
    func realmCacheStorePersistsValueAndMetadata() throws {
        let store = RealmCacheStore(configuration: inMemoryConfiguration(testName: #function))
        let genres = [Genre(id: 28, name: "Action")]

        store.save(genres, forKey: "genres", metadata: 4)

        #expect(store.load([Genre].self, forKey: "genres") == genres)
        #expect(store.metadata(forKey: "genres") == 4)
    }

    @Test
    func moviesCacheStoreLoadsSavedGenresAndPage() throws {
        let configuration = inMemoryConfiguration(testName: #function)
        let cacheStore = MoviesCacheStore(cacheStore: RealmCacheStore(configuration: configuration))
        let genres = [
            Genre(id: 28, name: "Action"),
            Genre(id: 12, name: "Adventure")
        ]
        let page = MoviesPage(
            page: 2,
            totalPages: 10,
            movies: [
                Movie(
                    id: 101,
                    title: "Example",
                    posterURL: "https://image.tmdb.org/t/p/w500/example.jpg",
                    backdropURL: nil,
                    year: "2026",
                    rating: 7.8,
                    genreIds: [28]
                )
            ]
        )

        cacheStore.saveGenres(genres)
        cacheStore.saveMoviesPage(page)

        #expect(cacheStore.loadGenres() == genres)
        #expect(cacheStore.loadMoviesPage(page: 2)?.page == 2)
        #expect(cacheStore.loadMoviesPage(page: 2)?.totalPages == 10)
        #expect(cacheStore.loadMoviesPage(page: 2)?.movies == page.movies)
    }

    @Test
    func movieDetailsCacheStoreLoadsSavedMovie() throws {
        let configuration = inMemoryConfiguration(testName: #function)
        let cacheStore = MovieDetailsCacheStore(cacheStore: RealmCacheStore(configuration: configuration))
        let movie = MovieDetails(
            id: 501,
            title: "Offline Movie",
            overview: "Stored locally",
            runtime: 115,
            releaseDate: "2026-04-12",
            genres: [Genre(id: 18, name: "Drama")],
            posterPath: "https://image.tmdb.org/t/p/w500/poster.jpg",
            backdropPath: nil,
            status: "Released",
            tagline: "Cached tagline",
            homepage: "https://example.com",
            budget: 1000,
            revenue: 2000,
            languages: ["English"]
        )

        cacheStore.save(movie)

        #expect(cacheStore.loadMovie(id: movie.id) == movie)
    }

    private func inMemoryConfiguration(testName: String) -> Realm.Configuration {
        Realm.Configuration(inMemoryIdentifier: "JahezTests.\(testName)")
    }
}
