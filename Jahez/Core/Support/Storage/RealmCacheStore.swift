//
//  RealmCacheStore.swift
//  Jahez
//
//  Created by Codex on 12/04/2026.
//

import Foundation
import RealmSwift

final class RealmCacheStore {

    private let configuration: Realm.Configuration
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(configuration: Realm.Configuration = .defaultConfiguration) {
        self.configuration = configuration
    }

    func save<Value: Encodable>(_ value: Value, forKey key: String, metadata: Int? = nil) {
        guard let data = try? encoder.encode(value),
              let realm = try? Realm(configuration: configuration) else {
            return
        }

        let entry = CachedPayloadObject()
        entry.key = key
        entry.payload = data
        entry.metadata = metadata ?? 0
        entry.updatedAt = Date()

        try? realm.write {
            realm.add(entry, update: .modified)
        }
    }

    func load<Value: Decodable>(_ type: Value.Type, forKey key: String) -> Value? {
        guard let realm = try? Realm(configuration: configuration),
              let entry = realm.object(ofType: CachedPayloadObject.self, forPrimaryKey: key) else {
            return nil
        }

        return try? decoder.decode(type, from: entry.payload)
    }

    func metadata(forKey key: String) -> Int? {
        guard let realm = try? Realm(configuration: configuration),
              let entry = realm.object(ofType: CachedPayloadObject.self, forPrimaryKey: key) else {
            return nil
        }

        return entry.metadata
    }
}

final class CachedPayloadObject: Object {
    @Persisted(primaryKey: true) var key: String
    @Persisted var payload: Data
    @Persisted var metadata: Int
    @Persisted var updatedAt: Date
}
