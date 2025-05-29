//
//  SolidProgressBar.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/28/25.
//

import SwiftUI

struct SolidProgressBar: View {
    var total: Int
    var currentIndex: Int
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 4) {
                HStack {
                    Spacer()
                    Text("\(currentIndex + 1) / \(total)")
                        .font(.caption.bold())
                        .foregroundStyle(Color.primaryBlue)
                }
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: geo.size.height)
                    Capsule()
                        .fill(Color.primaryBlue)
                        .frame(
                            width: geo.size.width * CGFloat(currentIndex + 1) / CGFloat(total),
                            height: geo.size.height)
                }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SolidProgressBar(total: 10, currentIndex: 7)
}
