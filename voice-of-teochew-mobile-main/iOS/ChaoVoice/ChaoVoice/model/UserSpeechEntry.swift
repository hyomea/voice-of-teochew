//
//  UserSpeechEntry.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 6/5/25.
//

import Foundation

struct UserSpeechEntry: Codable, Identifiable {
    var id: String
    var promptID: String
    var audioFileName: String
    var transcript: String?
    var deviceID: String
    var createdAt: Date
}
