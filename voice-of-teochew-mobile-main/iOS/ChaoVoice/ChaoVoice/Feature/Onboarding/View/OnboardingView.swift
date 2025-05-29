//
//  OnboardingView.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var userProfile: UserProfile
    var body: some View {
        GeometryReader { geo in
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    background: Image("onboarding-1"),
                    title: "onboarding.title.1",
                    description: "onboarding.description.1",
                    width: geo.size.width,
                    height: geo.size.height
                )
                .tag(0)
                
                OnboardingPageView(
                    background: Image("onboarding-2"),
                    title: "onboarding.title.2",
                    description: "onboarding.description.2",
                    width: geo.size.width,
                    height: geo.size.height
                )
                .tag(1)
                
                OnboardingForm(
                    userProfile: $userProfile,
                    background: Image("onboarding-3"),
                    width: geo.size.width,
                    height: geo.size.height
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .animation(.easeInOut, value: currentPage)
        }
        .ignoresSafeArea()
    }
}

//#Preview {
//    OnboardingView()
//}
