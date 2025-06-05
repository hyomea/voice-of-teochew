//
//  SpeakingView.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct SpeakingCardView: View {
    @State private var showingEnglish = false
    @State private var showContent = true
    var prompt: PromptItem

    let flipDuration = 0.6

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                if !showingEnglish {
                    CardFace {
                        Group {
                            if showContent {
                                FrontCard(prompt: prompt)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }

                if showingEnglish {
                    CardFace {
                        Group {
                            if showContent {
                                BackCard(prompt: prompt)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
            }
            .rotation3DEffect(.degrees(showingEnglish ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.easeInOut(duration: flipDuration), value: showingEnglish)
            .onChange(of: showingEnglish) { _, _ in
                showContent = false
                DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration / 2) {
                    showContent = true
                }
            }
            .onTapGesture {
                showingEnglish.toggle()
            }
        }
        .padding(18)
    }
}

struct CardFace<Content: View>: View {
    let content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 8)

            content()
                .padding()
        }
    }
}



// MARK: - Front Card
struct FrontCard: View {
    var prompt: PromptItem
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(prompt.explanation)
                .font(.title)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 36)

        }
    }
}

// MARK: - Back Card
struct BackCard: View {
    var prompt: PromptItem
    @State private var showHint: Bool = false
    var body: some View {
        VStack {
            if let teochew = prompt.teochew {
                HStack {
                    Text("card.teochew.label")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button {
                        showHint = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .alert(
                        Text("teochew_hint.title".localized()),
                        isPresented: $showHint
                    ) {
                        Button("ok.button".localized(), role: .cancel) {}
                    } message: {
                        Text("teochew_hint.message".localized())
                    }

                }

                Text(teochew)
                    .font(.title)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 48)
            }
            if let english = prompt.english {
                VStack(alignment: .center) {
                    Text("card.english.label")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(english)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}
