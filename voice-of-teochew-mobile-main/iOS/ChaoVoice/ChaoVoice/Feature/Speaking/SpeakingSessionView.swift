//
//  SpeakingView.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct SpeakingSessionView: View {
    @State private var isRecording = false
    @State private var currentIndex = 0
    @StateObject private var recordingManager = RecordingManager.shared
    var body: some View {
        VStack {
            SolidProgressBar(total: 6, currentIndex: currentIndex)
                .frame(height: 10)
                .padding()
            TabView(selection: $currentIndex) {
                ForEach(0...5, id: \.self) { index in
                    SpeakingCardView(prompt: "你吃饭没有？")
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            HStack {
                MicButton(id: $currentIndex)
                    .environmentObject(recordingManager)
            }
            .frame(height: 48)
            .padding()
        }
    }
}

#Preview {
    SpeakingSessionView()
}
