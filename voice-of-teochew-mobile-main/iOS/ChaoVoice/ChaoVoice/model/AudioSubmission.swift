//
//  Submission.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/29/25.
//
import Foundation

struct AudioSubmission: Identifiable, Codable {
    var id: String
    var userId: String
    var createDate: Date
    var audioURL: URL
    var promptId: String
    var feedback: String?
}
