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
            let width = geo.size.width
            let height = geo.size.height
            let safeTotal = max(total, 1) // avoid division by zero
            let progressWidth = width * CGFloat(currentIndex + 1) / CGFloat(safeTotal)

            VStack(spacing: 4) {
                HStack {
                    Spacer()
                    Text("\(currentIndex + 1) / \(safeTotal)")
                        .font(.caption.bold())
                        .foregroundStyle(Color.primaryBlue)
                }
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: height)
                    Capsule()
                        .fill(Color.primaryBlue)
                        .frame(
                            width: progressWidth,
                            height: height
                        )
                }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SolidProgressBar(total: 10, currentIndex: 7)
}
