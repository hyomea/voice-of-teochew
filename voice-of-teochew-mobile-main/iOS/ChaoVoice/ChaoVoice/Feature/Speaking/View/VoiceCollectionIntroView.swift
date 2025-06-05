//
//  VoiceCollectionIntroView.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 6/3/25.
//

import SwiftUI

struct VoiceCollectionIntroView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("voice_collection.title".localized())
                    .font(.title)
                    .bold()
                
                SectionHeaderView(title: "what_you_do.title", context: "what_you_do.body")
                SectionHeaderView(title: "why_it_matters.title", context: "why_it_matters.body")
                SectionHeaderView(title: "speaking_guidelines.title", context: "speaking_guidelines.body")
                SectionHeaderView(title: "note.title", context: "note.body")
                
                Spacer()
            }
            .padding()
        }
    }
}

// Reusable section component
struct SectionHeaderView: View {
    let title: String
    let context: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.localized())
                .font(.headline)
            
            Text(context.localized())
                .lineSpacing(6)
        }
    }
}

// LocalizedStringKey extension
extension String {
    func localized() -> LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}
