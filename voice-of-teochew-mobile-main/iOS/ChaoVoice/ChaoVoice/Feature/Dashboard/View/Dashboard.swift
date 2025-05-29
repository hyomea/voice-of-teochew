//
//  Dashboard.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct Dashboard: View {
    let cols = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    let spacing: CGFloat = 16

    @State private var scrollOffset: CGFloat = 0
    @State private var selectedCategory: SpeechCollectionCategory? = nil
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
                        ForEach(SpeechCollectionCategory.allCases, id: \.id) { category in
                            DashboardCardView(category: category) {
                                selectedCategory = category
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
            .navigationDestination(item: $selectedCategory) { category in
                SpeakingSessionView()
            }
        }
        .tint(Color.textPrimary)
    }
    
    @ViewBuilder
    func DashboardCardView(
        category: SpeechCollectionCategory,
        onClick: @escaping () -> Void
    ) -> some View {
        ZStack {
            Image(category.backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.4)
                .clipped()
                .cornerRadius(12)

            VStack(spacing: 12) {
                Image(systemName: category.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)

                Text(category.localizedLabel)
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
