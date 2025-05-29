//
//  MicButton.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//
import SwiftUI

struct MicButton: View {
    @EnvironmentObject var permissionManager: PermissionManager
    @EnvironmentObject var recordingManager: RecordingManager
    @Binding var id: Int
    
    @State private var showPermissionAlert = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    private let maxDuration: TimeInterval = 15
    private var recordingProgress: Double {
        min(elapsedTime / maxDuration, 1)
    }
    var body: some View {
        VStack(spacing: 12) {
            if !recordingManager.isRecording && self.elapsedTime == 0 {
                Image(systemName:"mic.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color.primaryBlue)
                    .onTapGesture {
                        if permissionManager.micPermissionStatus == .authorized {
                            print("authorized")
                            if !recordingManager.isRecording {
                                startRecording()
                            }
                        } else {
                            print("not authorized")
                            Task {
                                await requestPermissionAndMaybeRecord()
                            }
                        }
                    }
            } else {
                HStack(spacing: 8) {
                    Button {
                        self.cancelRecording()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .font(.system(size: 24).bold())
                    .foregroundStyle(Color.gray)
                    // Show recording progress by the timer, progress to the left
                    DashedProgressBar(progress: recordingProgress)
                    
                    Text(formatTime(elapsedTime))
                        .frame(width: 60)
                        .font(.caption)
                    HStack {
                        if recordingManager.isRecording {
                            HStack {
                                Button {
                                    recordingManager.stopRecording()
                                    timer?.invalidate()
                                } label: {
                                    Image(systemName: "stop.circle")
                                }
                                .font(.system(size: 24).bold())
                                .foregroundStyle(Color.primaryBlue)
                                
                                Spacer(minLength: 0)
                            }
                        }
                        
                        if !recordingManager.isRecording && self.elapsedTime > 0 {
                            HStack {
                                Button {
                                    // play recording
                                    recordingManager.togglePlaying()
                                } label: {
                                    Image(systemName: recordingManager.isPlaying ? "pause.circle" : "play.circle")
                                }
                                .font(.system(size: 24).bold())
                                .foregroundStyle(Color.primaryBlue)
                                
                                Spacer(minLength: 0)

                                Button {
                                    self.submitRecording()
                                } label: {
                                    Text("mic_button.submit")
                                }
                                .font(.caption)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .foregroundStyle(Color.white)
                                .background(Color.primaryBlue)
                                .cornerRadius(8)
                            }
                        }
                            
                    }
                    .frame(minWidth: 80)
                    
                }
            }

            if !recordingManager.isRecording && self.elapsedTime == 0 {
                Text("mic_permission.hint")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .transition(.opacity)
            }
        }
        .onChange(of: id, { _, _ in
            self.reset()
        })
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("mic_permission.alert_title"),
                message: Text("mic_permission.alert_message"),
                primaryButton: .default(Text("mic_permission.open_settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel(Text("mic_permission.cancel"))
            )
        }

    }

    private func requestPermissionAndMaybeRecord() async {
        let status = await permissionManager.requestMicPermission()
        if status != .authorized {
            showPermissionAlert = true
        }
    }

    private func startRecording() {
        print("🎙️ Start recording")
        recordingManager.startRecording()
        elapsedTime = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            if elapsedTime >= maxDuration {
                recordingManager.stopRecording()
                timer?.invalidate()
            } else {
                elapsedTime += 0.5
            }
        })
    }

    private func cancelRecording() {
        print("🛑 Stop recording")
        timer?.invalidate()
        recordingManager.stopRecording()
        elapsedTime = 0
    }
    
    private func submitRecording() {
        print("🛑 Complete recording")
        // submit recording
        timer?.invalidate()
    }
    
    private func reset() {
        self.recordingManager.reset()
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: interval) ?? "0:00"
    }
}

