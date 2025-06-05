//
//  DashboardViewModel.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/30/25.
//

import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var collections: [PromptCollection] = []
    let dataProvider: PromptCollectionProvider
    
    init(dataProvider: PromptCollectionProvider = PromptCollectionProvider.shared) {
        self.dataProvider = dataProvider
    }
    
    func loadLocalCollections() {
        self.collections = dataProvider.loadLocalCollections()
    }
}
