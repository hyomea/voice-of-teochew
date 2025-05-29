//
//  ContentView.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var permissionManager = PermissionManager.shared
    @State private var userProfile = UserProfile.load()
    var body: some View {
        ZStack {
            if userProfile.isCompleted {
                Dashboard()
//                SpeakingView()
//                    .transition(.opacity)
            } else {
                OnboardingView(userProfile: $userProfile)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: userProfile.isCompleted)
        .environmentObject(permissionManager)
    }
}

#Preview {
    ContentView()
}
