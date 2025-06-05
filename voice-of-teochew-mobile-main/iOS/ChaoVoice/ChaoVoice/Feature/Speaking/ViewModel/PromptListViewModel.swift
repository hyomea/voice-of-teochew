//
//  DashboardViewModel.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/30/25.
//

import Foundation

@MainActor
final class PromptListViewModel: ObservableObject {
    @Published var prompts: [PromptItem] = []
    let dataProvider: PromptCollectionProvider
    
    let selectedCollection: PromptCollection
    
    init(dataProvider: PromptCollectionProvider = PromptCollectionProvider.shared, selected: PromptCollection) {
        self.dataProvider = dataProvider
        self.selectedCollection = selected

        Task { [weak self] in
            await self?.loadLocalCollections()
        }
        
    }
    
    func loadLocalCollections() async {
        self.prompts = await dataProvider.loadCollectionList(for: self.selectedCollection)
    }
}
