//
//  SpeechCollection.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/29/25.
//

import Foundation

struct PromptCollection: Identifiable, Codable, Equatable, Hashable {
    let id: String           // from API
    let name: String         // in Chinese
    let englishName: String? // optional English name
    let tags: [String]       // optional tags
    let totalCount: Int      // number of prompts
    var source: String?        // local or remote

    var iconName: String {
        if id == "community" {
            return "plus.square.on.square.fill"
        }
        return "quote.bubble"
    }

    var backgroundImage: String {
        let index = localIndex ?? 0
        return "card-\((index % 4) + 1)" // cycles through card-1 to card-4
    }

    var localIndex: Int? // set locally after fetch
    
    var displayName: String {
        let isEnglish = Locale.preferredLanguages.first?.hasPrefix("en") ?? false
        return isEnglish ? (englishName ?? name) : name
    }
}
