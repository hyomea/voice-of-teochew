//
//  SpeechCollection.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/29/25.
//

struct PromptCollection: Identifiable, Codable, Equatable {
    let id: String           // from API
    let name: String         // in Chinese
    let englishName: String? // optional English name
    let tags: [String]       // optional tags
    let totalCount: Int      // number of prompts
    let source: String       // local or remote

    var iconName: String { "quote.bubble" }

    var backgroundImage: String {
        let index = localIndex ?? 0
        return "card-\((index % 4) + 1)" // cycles through card-1 to card-4
    }

    var localIndex: Int? // set locally after fetch
}
