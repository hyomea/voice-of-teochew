//
//  PromptItem.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/29/25.
//

import Foundation

struct PromptItem: Identifiable, Codable, Hashable {
    let id: String
    let teochew: String?
    let explanation: String
    let english: String?
    
    let creatorId: String?
    let createdAt: Date?
}

