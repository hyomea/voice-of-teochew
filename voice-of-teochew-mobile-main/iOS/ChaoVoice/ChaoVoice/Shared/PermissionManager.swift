//
//  PermissionManager.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import Foundation
import AVFoundation

enum PermissionStatus {
    case notDetermined
    case authorized
    case denied
    case restricted
}

@MainActor
final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()
    @Published private(set) var micPermissionStatus: PermissionStatus

    private init() {
        self.micPermissionStatus = PermissionManager.getCurrentMicPermissionStatus()
    }
        
    func requestMicPermission() async -> PermissionStatus {
        await withCheckedContinuation { continuation in
            let handler: (Bool) -> Void = { granted in
                let status: PermissionStatus = granted ? .authorized : .denied
                DispatchQueue.main.async {
                    self.micPermissionStatus = status
                    continuation.resume(returning: status)
                }
            }
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission(completionHandler: handler)
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission(handler)
            }
        }
    }
    
    func checkMicPermissionStatus() {
        micPermissionStatus = Self.getCurrentMicPermissionStatus()
    }
    
    private static func getCurrentMicPermissionStatus() -> PermissionStatus {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .undetermined: return .notDetermined
            case .denied: return .denied
            case .granted: return .authorized
            @unknown default: return .notDetermined
            }
        } else {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .undetermined: return .notDetermined
            case .denied: return .denied
            case .granted: return .authorized
            @unknown default: return .notDetermined
            }
        }
    }
    
    private let hasExplainedMicKey = "hasExplainedMicPermission"

    var shouldShowMicExplanation: Bool {
        !UserDefaults.standard.bool(forKey: hasExplainedMicKey)
    }

    func markMicExplanationShown() {
        UserDefaults.standard.set(true, forKey: hasExplainedMicKey)
    }

}
