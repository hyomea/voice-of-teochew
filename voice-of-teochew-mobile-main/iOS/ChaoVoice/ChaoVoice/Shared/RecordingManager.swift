//
//  RecordingManager.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/28/25.
//

import Foundation
import AVFoundation

final class RecordingManager: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    static let shared = RecordingManager()
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    
    @Published private(set) var isRecording = false
    @Published private(set) var isPlaying = false
    @Published var recordingURL: URL?
    
    private override init() {}
    
    private var recordingSettings: [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    private func getTempRecordingURL() -> URL {
        let fileName = UUID().uuidString + ".m4a"
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
    
    func startRecording() {
        let url = getTempRecordingURL()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            
            recorder = try AVAudioRecorder(url: url, settings: recordingSettings)
            recorder?.delegate = self
            recordingURL = url

            recorder?.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        isRecording = false
    }
    
    func cancelRecording() {
        recorder?.stop()
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
        isRecording = false
    }
    
    func playRecording() {
        guard let url = recordingURL else {
            print("can't get url for recording")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            isPlaying = true
        } catch {
            print("failed to play: \(error.localizedDescription)")
        }
    }
    
    func stopPlayback() {
        player?.stop()
        isPlaying = false
    }
    
    func togglePlaying() {
        if self.isPlaying {
            self.stopPlayback()
        } else {
            self.playRecording()
        }
    }
    
    func reset() {
        stopPlayback()
        cancelRecording()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
