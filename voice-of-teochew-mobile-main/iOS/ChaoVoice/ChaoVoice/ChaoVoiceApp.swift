//
//  ChaoVoiceApp.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

@main
struct ChaoVoiceApp: App {
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "PrimaryBlue")
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        UINavigationBar.appearance().barTintColor = UIColor(named: "PrimaryBlue")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
