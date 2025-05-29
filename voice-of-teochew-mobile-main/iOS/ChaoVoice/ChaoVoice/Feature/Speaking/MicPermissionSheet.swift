//
//  MicPermissionSheet.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//
import SwiftUI

struct MicPermissionSheet: View {
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("mic_permission.title")
                .font(.title2.bold())

            Text("mic_permission.description")
                .multilineTextAlignment(.center)

            HStack(spacing: 24) {
                Button("mic_permission.cancel") {
                    onCancel()
                }

                Button("mic_permission.confirm") {
                    onConfirm()
                }
                .bold()
            }
        }
        .padding()
    }
}
