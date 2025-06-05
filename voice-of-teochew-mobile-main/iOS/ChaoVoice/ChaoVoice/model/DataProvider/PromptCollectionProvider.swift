//
//  PromptCollectionProvider.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/30/25.
//
import Foundation
final class PromptCollectionProvider {
    static let shared = PromptCollectionProvider()
    private init() {}
    
    func loadLocalCollections(fileName: String = "prompt_collections") -> [PromptCollection] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Local file not found")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let parsedData = try JSONDecoder().decode(PromptCollectionsResponse.self, from: data)
            let collections = parsedData.collections.map { collection in
                var copy = collection
                if copy.id == "community" {
                    copy.source = "remote"
                } else {
                    copy.source = "local"
                }
                return copy
            }
            return collections
        } catch {
            print("Failed to decode local collections: \(error)")
            return []
        }
    }
    
    func loadCollectionList(for collection: PromptCollection) async -> [PromptItem] {
        if collection.source == "local" {
            guard let url = Bundle.main.url(forResource: collection.id, withExtension: "json") else {
                print("Local list not found")
                return []
            }
            do {
                let data = try Data(contentsOf: url)
                let parsedDate = try JSONDecoder().decode(PromptList.self, from: data)
                let deviceId = UserProfile.getDeviceID()
                let seed = UserProfile.seedFromString(deviceId)
                var geneerator = SeededGenerator(seed: seed)
                return parsedDate.items.shuffled(using: &geneerator)  // make sure the distribution of samples
            } catch {
                print("error parsing list data: \(error)")
                return []
            }
        } else {
            return []
        }
    }
    
}
