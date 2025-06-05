//
//  PromptList.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/29/25.
//

struct PromptList: Codable {
    var collectionId: String
    var source: String
    var version: Int
    var items: [PromptItem]
}
