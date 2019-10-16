//
//  ActivityRing.swift
//  pomo
//
//  Created by khoi on 10/12/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI
import Combine

struct ActivityRing: View {
    @Binding var progress: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dashPhase: 0))
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.pink, style: StrokeStyle(lineWidth: 10, lineCap: .round, dashPhase: 0))
                .rotationEffect(.degrees(-90))
                .animation(Animation.default)
            
        }
        
    }
}

struct ActivityRing_Previews: PreviewProvider {
    @State static var empty: CGFloat = 0
    @State static var halfFull: CGFloat = 0.5
    @State static var full: CGFloat = 1
    
    static var previews: some View {
        Group {
            ActivityRing(progress: $empty)
            ActivityRing(progress: $halfFull)
            ActivityRing(progress: $full)
            
        }
        .previewLayout(PreviewLayout.fixed(width: 300, height: 300))
    }
}
