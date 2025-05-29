//
//  DashedProgressBar.swift
//  ChaoVoice
//
//  Created by Xiaomei Huang on 5/28/25.
//

import SwiftUI

struct DashedProgressBar: View {
    var progress: CGFloat // value between 0.0 and 1.0
    var height: CGFloat = 10
    var dotWidth: CGFloat = 3
    var spacing: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let segmentUnit = dotWidth + spacing
            let totalSegments = Int(totalWidth / segmentUnit)
            let activeSegments = Int(CGFloat(totalSegments) * progress)

            HStack(spacing: spacing) {
                ForEach(0..<totalSegments, id: \.self) { index in
                    Capsule()
                        .frame(width: dotWidth, height: height)
                        .foregroundStyle(index < activeSegments ? Color.primaryBlue : Color.gray.opacity(0.3))
                }
            }
            .frame(width: totalWidth, alignment: .leading)
        }
        .frame(height: height)
    }
}


#Preview {
    DashedProgressBar(progress: 0.5)
}
