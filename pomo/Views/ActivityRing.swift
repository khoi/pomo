//
//  ActivityRing.swift
//  pomo
//
//  Created by khoi on 10/12/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Combine
import SwiftUI

struct ActivityRing: View {
  var progress: CGFloat

  var body: some View {
    ZStack {
      Circle()
        .stroke(Color.gray,
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dashPhase: 0))

      Circle()
        .trim(from: 0, to: progress)
        .stroke(Color.pink, style: StrokeStyle(lineWidth: 10, lineCap: .round, dashPhase: 0))
        .rotationEffect(.degrees(-90))
        .animation(.default)
    }
  }
}

struct ActivityRing_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ActivityRing(progress: 0)
      ActivityRing(progress: 0.5)
      ActivityRing(progress: 1)
    }
    .previewLayout(PreviewLayout.fixed(width: 300, height: 300))
  }
}
