//
//  ContributeCardView.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 6/4/25.
//

import SwiftUI

struct ContributeCardView: View {
    @State private var meaningText = ""
    @State private var audioURL: URL? = nil
    @State private var showInstruction = false

    @StateObject private var recordingManager = RecordingManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("contribute.meaning.title")
                .font(.headline)
            TextEditor(text: $meaningText)
                .frame(height: 200)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

            VStack(alignment: .center) {
                MicButton(
                    id: Binding.constant(0),
                    disabled: meaningText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    onSubmit: {
                    //
                })
                    .environmentObject(recordingManager)
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding()
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
            InstructionView()
        }
    }
    
    @ViewBuilder
    func InstructionView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("contribute.instruction.title".localized())
                    .font(.title2)
                    .bold()
                
                Text("contribute.instruction.step1".localized())
                Text("contribute.instruction.step2".localized())
                Text("contribute.instruction.step3".localized())
                Text("contribute.instruction.tip".localized())
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
            .padding()
        }
    }
}


#Preview {
    ContributeCardView()
}
