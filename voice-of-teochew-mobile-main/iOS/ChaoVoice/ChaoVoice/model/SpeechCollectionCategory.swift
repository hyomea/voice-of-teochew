//
//  SpeechCollectionCategory.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUICore

enum SpeechCollectionCategory: String, CaseIterable, Identifiable, Codable {
    case greetings
    case food
    case idioms
    case family
    case market
    case festival
    case school
    case tea
    case emotions
    case children
    case rhymes      // 顺口溜
    case jokes       // 笑话

    var id: String { rawValue }

    var localizedLabel: String {
        NSLocalizedString("collection.\(rawValue)", comment: "")
    }
}

extension SpeechCollectionCategory {
    var iconName: String {
        switch self {
        case .greetings: return "hands.sparkles"
        case .food: return "fork.knife.circle"
        case .idioms: return "quote.bubble"
        case .family: return "house.and.flag"
        case .market: return "cart.fill"
        case .festival: return "sparkles"
        case .school: return "book.closed.fill"
        case .tea: return "cup.and.saucer.fill"
        case .emotions: return "face.smiling"
        case .children: return "figure.child"
        case .rhymes: return "music.note"
        case .jokes: return "face.smiling.fill"
        }
    }
    
    var backgroundImage: String {
        switch self {
        case .greetings: return "card-1"
        case .food: return "card-2"
        case .idioms: return "card-3"
        case .family: return "card-4"
        case .market: return "card-1"
        case .festival: return "card-2"
        case .school: return "card-3"
        case .tea: return "card-4"
        case .emotions: return "card-1"
        case .children: return "card-2"
        case .rhymes: return "card-3"
        case .jokes: return "card-4"
        }
    }
}
