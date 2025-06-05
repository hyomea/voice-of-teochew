//
//  PromptCollectionsResponse.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/30/25.
//

struct PromptCollectionsResponse: Codable {
    let version: Int
    let collections: [PromptCollection]
}
