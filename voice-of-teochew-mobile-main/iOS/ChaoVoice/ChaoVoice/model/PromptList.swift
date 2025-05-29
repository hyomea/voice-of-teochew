//
//  PromptList.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/29/25.
//

struct PromptList: Identifiable, Codable {
    var collectionId: String
    var source: String
    var version: Int
    var items: [PromptItem]
    var id: String { collectionId }
}
