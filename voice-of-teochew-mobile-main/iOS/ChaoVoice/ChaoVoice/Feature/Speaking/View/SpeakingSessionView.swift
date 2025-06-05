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
    @State private var showInstruction = false
    @StateObject private var recordingManager = RecordingManager.shared
    @ObservedObject var viewModel: PromptListViewModel
    var body: some View {
        VStack {
            SolidProgressBar(total: viewModel.prompts.count, currentIndex: currentIndex)
                .frame(height: 10)
                .padding()
            TabView(selection: $currentIndex) {
                ForEach(Array(viewModel.prompts.enumerated()), id: \.element.id) { index, prompt in
                    SpeakingCardView(prompt: prompt)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            HStack {
                MicButton(id: $currentIndex, disabled: false)
                    .environmentObject(recordingManager)
            }
            .frame(height: 48)
            .padding()
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showInstruction = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }

            }
        }
        .sheet(isPresented: $showInstruction) {
            speakingInstructionView
        }
    }
    
    private var speakingInstructionView: some View {
        VStack {
            VoiceCollectionIntroView()
        }
    }
}

//#Preview {
//    SpeakingSessionView()
//}
