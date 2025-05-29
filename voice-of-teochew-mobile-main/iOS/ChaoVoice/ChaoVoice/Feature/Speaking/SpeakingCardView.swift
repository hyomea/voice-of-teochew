//
//  SpeakingView.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct SpeakingCardView: View {
    let prompt: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 8)

            VStack(spacing: 24) {
                Text(prompt)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

            }
            .padding()
        }
        .padding()
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if abs(value.translation.width) > 100 {
                        skipCard()
                    }
                }
        )
    }

    private func skipCard() {
        // Trigger next card or mark as skipped
        print("Card skipped")
    }
}


//#Preview {
//    SpeakingView()
//}
