//
//  HomeContainerView.swift
//  pomo
//
//  Created by khoi on 10/31/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct HomeContainer: View {
  @EnvironmentObject var store: Store<AppState, AppAction>
  @State var now: Date = Date()

  var timer: Timer {
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      self.now = Date()
    }
  }

  var body: some View {
    return VStack {
      store.state.started.map { ViewBuilder.buildEither(first: Text("\($0.timeIntervalSince(self.now))")) }
        ??
        ViewBuilder.buildEither(second: Button("Start") {
          self.store.send(.startTimer)
        })
    }.onAppear {
      _ = self.timer
    }
  }
}

struct HomeContainerView_Previews: PreviewProvider {
  static var previews: some View {
    HomeContainer()
  }
}
