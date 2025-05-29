//
//  OnboardingPageView.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let background: Image
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let width: CGFloat
    let height: CGFloat
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                background
                    .resizable()
                    .frame(width: width, height: height)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 36) {
                    Text(title)
                        .font(.largeTitle.bold())

                    Text(description)
                        .font(.system(size: 24))
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity) // force expand
                        .multilineTextAlignment(.center)
                    
                }
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 12)
                .padding(.top, 48)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack {
        GeometryReader { geo in
            OnboardingPageView(
                background: Image("onboarding-1"),
                title: "潮声集",
                description: "Welcome to the Teochew speech collection project.\nLet language become a bridge to our memories.",
                width: geo.size.width,
                height: geo.size.height
            )
        }
    }

}
