//
//  PromptItem.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/29/25.
//

struct PromptItem: Identifiable, Codable {
    let id: String
    let collectionId: String
    let teochew: String?
    let explanation: String
    let english: String?
}

