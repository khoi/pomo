//
//  CircleProgressView.swift
//  pomo
//
//  Created by khoi on 12/23/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

public struct CircleProgressView: View {
  let progress: Double

  public var body: some View {
    GeometryReader { geometry in
      Path { path in
        let radius: CGFloat = min(geometry.size.width, geometry.size.height) / 2
        let mid = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        path.addArc(center: mid,
                    radius: radius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: self.progress.map(from: 0 ... 1, to: -90 ... 270)),
                    clockwise: false)
        path.addLine(to: mid)
        path.closeSubpath()
      }
      .fill()
    }
  }
}

extension Double {
  func map(from: ClosedRange<Double>, to: ClosedRange<Double>) -> Double {
    return ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
  }
}

#if DEBUG
  struct CircleProgressView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        CircleProgressView(
          progress: 0.25
        )
        CircleProgressView(
          progress: 0.50
        )
        CircleProgressView(
          progress: 0.75
        )
        CircleProgressView(
          progress: 1
        )
      }
      .foregroundColor(.blue)
      .frame(width: 100, height: 100)
      .previewLayout(PreviewLayout.fixed(width: 100, height: 100))
    }
  }
#endif
