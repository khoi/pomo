//
//  HomeContainerView.swift
//  pomo
//
//  Created by khoi on 10/31/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct HomeContainer: View {
  @EnvironmentObject var store: Store<AppState, AppMutation>

  @State var timeLeft: TimeInterval = 0

  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    VStack(spacing: 16) {
      ZStack {
        ActivityRing(progress: ringProgress(timeLeft: self.timeLeft, duration: self.store.state.defaultDuration))
        Text(format(duration: self.timeLeft))
          .font(.largeTitle)
      }
      .padding(16)

      Button(action: {
        self.store.dispatch(self.timerStarted ? AppAction.stopTimer : AppAction.startTimer)
      }) {
        Image(systemName: self.timerStarted ? "pause.circle" : "play.circle")
          .font(.largeTitle)
          .foregroundColor(.pink)
      }
    }
    .onReceive(timer) { _ in
      guard let started = self.store.state.started else {
        self.timeLeft = self.store.state.defaultDuration
        return
      }
      let timeLeft = self.store.state.defaultDuration - Date().timeIntervalSince(started)
      if timeLeft <= 0 {
        self.store.dispatch(AppAction.stopTimer)
        return
      }
      self.timeLeft = timeLeft
    }
  }

  var timerStarted: Bool {
    store.state.started != nil
  }

  func ringProgress(timeLeft: TimeInterval, duration: TimeInterval) -> CGFloat {
    let progress = timeLeft / duration
    return CGFloat(max(0, min(1, progress)))
  }

  func format(duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    formatter.maximumUnitCount = 1
    return formatter.string(from: duration)!
  }
}

struct HomeContainerView_Previews: PreviewProvider {
  static var previews: some View {
    HomeContainer()
      .environmentObject(Store<AppState, AppMutation>(state: AppState(), mutator: appMutator))
  }
}
