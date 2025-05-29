//
//  DashboardHeader.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/27/25.
//

import SwiftUI

struct DashboardHeader: View {
    let contributionCount: Int
    let streakCount: Int
    @State private var animateStreak = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(greetingText)
                    .font(.title2.bold())
                    .transition(.opacity)
                    .animation(.easeInOut, value: greetingText)
                Spacer()
                
                if streakCount > 1 {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .scaleEffect(animateStreak ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true), value: animateStreak)
                        Text("\(streakCount)")
                            .font(.headline)
                        Text(LocalizedStringKey("dashboard.streak_days"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.top, 4)
                    .onAppear {
                        animateStreak = true
                    }
                }

            }

            HStack {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
                
                if contributionCount > 0 {
                    Text(String(localized: "dashboard.contribution_count \(contributionCount)"))
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                }
            }


        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return String(localized: "dashboard.greeting.morning")
        case 12..<17: return String(localized: "dashboard.greeting.afternoon")
        case 17..<22: return String(localized: "dashboard.greeting.evening")
        default: return String(localized: "dashboard.greeting.night")
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
}
