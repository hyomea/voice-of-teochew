//
//  UserProfile.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//
import Foundation
import SwiftUICore

struct UserProfile: Codable {
    var nickName: String = ""
    var ageGroup: AgeGroup = .unspecified
    var dialectTag: DialectTag = .unsure
    var isCompleted: Bool = false
    
    enum AgeGroup: String, CaseIterable, Identifiable, Codable {
        case unspecified = "age.unspecified"
        case under18 = "age.under18"
        case eighteenToForty = "age.18_40"
        case fortyToSixty = "age.40_60"
        case sixtyPlus = "age.60plus"
        
        var id: String { rawValue }
    }

    enum DialectTag: String, CaseIterable, Identifiable, Codable {
        case chaozhouCore = "dialect.chaozhou_core"
        case chaozhouOutskirts = "dialect.chaozhou_outskirts"
        case jieyang = "dialect.jieyang"
        case puning = "dialect.puning"
        case shantou = "dialect.shantou"
        case chenghai = "dialect.chenghai"
        case overseas = "dialect.overseas"
        case passive = "dialect.passive"
        case unsure = "dialect.unsure"

        var id: String { rawValue }

        var localizedLabel: LocalizedStringKey {
            LocalizedStringKey(self.rawValue)
        }
    }

}

extension UserProfile {
    private static let key = "user_profile"
    
    func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }
    static func load() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: Self.key), let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        } else {
            return UserProfile()
        }
    }
    
    static func getDeviceID() -> String {
        let key = "app.doraimon.deviceID"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        } else {
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: key)
            return newID
        }
    }
    
    static func seedFromString(_ string: String) -> UInt64 {
        var hasher = Hasher()
        hasher.combine(string)
        hasher.combine("v1")
        return UInt64(bitPattern: Int64(hasher.finalize()))
    }
}
