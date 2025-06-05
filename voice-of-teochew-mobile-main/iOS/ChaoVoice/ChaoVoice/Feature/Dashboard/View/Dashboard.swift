//
//  Dashboard.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct Dashboard: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedCollection: PromptCollection? = nil
    @StateObject private var viewModel = DashboardViewModel()
    
    let cols = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    let spacing: CGFloat = 16

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        let offset = geo.frame(in: .named("scroll")).minY
                        DashboardHeader(contributionCount: 12, streakCount: 7)
                            .opacity(opacity(for: offset))
                            .scaleEffect(scale(for: offset))
                            .frame(height: 100)
                            .background(Color.background)
                            .preference(key: ScrollOffsetKey.self, value: offset)
                    }
                    .frame(height: 100)

                    LazyVGrid(columns: cols, spacing: spacing) {
                        ForEach(viewModel.collections, id: \.id) { collection in
                            DashboardCardView(collection: collection) {
                                selectedCollection = collection
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
            }
            .coordinateSpace(name: "scroll")
            .background(Color.background)
            .navigationDestination(item: $selectedCollection) { collection in
                if collection.id == "community" {
                    ContributeCardView()
                } else {
                    SpeakingSessionView(viewModel: PromptListViewModel(selected: collection))
                }
            }
        }
        .tint(Color.textPrimary)
        .onAppear {
            viewModel.loadLocalCollections()
        }
    }
    
    @ViewBuilder
    func DashboardCardView(
        collection: PromptCollection,
        onClick: @escaping () -> Void
    ) -> some View {
        ZStack {
            Image(collection.backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.4)
                .clipped()
                .cornerRadius(12)

            VStack(spacing: 12) {
                Image(systemName: collection.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)

                Text(collection.displayName)
                    .font(.headline)
            }
            .foregroundStyle(Color.textPrimary)
        }
        .frame(height: 120)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
        .onTapGesture {
            onClick()
        }
    }

    // Helpers
    private func opacity(for offset: CGFloat) -> Double {
        let value = 1 - (offset / 80)
        return Double(min(max(value, 0.3), 1))
    }

    private func scale(for offset: CGFloat) -> CGFloat {
        let value = 1 - (offset / 500)
        return CGFloat(min(max(value, 0.85), 1))
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    Dashboard()
}
