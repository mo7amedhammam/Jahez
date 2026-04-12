//
//  LanguageManager.swift
//  Jahez
//
//  Created by mohamed hammam on 12/04/2026.
//

enum AppLanguage: String {
    case english = "en-US"
    case arabic = "ar-EG"
}

class LanguageManager {
    static var current: AppLanguage = .english
}
