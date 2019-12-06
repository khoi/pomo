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

  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

  var body: some View {
    ZStack {
      Color(appBackgroundColor)
        .edgesIgnoringSafeArea(.all)
      VStack(spacing: 16) {
        Text("Work").font(.subheadline)
          .foregroundColor(appTextColor)

        Text(format(duration: self.timeLeft))
          .font(.largeTitle)
          .foregroundColor(appTextColor)
          .padding()
        Button(action: {
          self.store.dispatch(self.timerStarted ? AppAction.stopTimer : AppAction.startTimer)
        }) {
          Image(systemName: self.timerStarted ? "pause" : "play")
            .font(.largeTitle)
            .foregroundColor(.blue)
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
  }

  var timerStarted: Bool {
    store.state.started != nil
  }

  func format(duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    formatter.maximumUnitCount = 0
    return formatter.string(from: duration)!
  }
}

struct HomeContainerView_Previews: PreviewProvider {
  static var previews: some View {
    HomeContainer()
      .environmentObject(Store<AppState, AppMutation>(state: AppState(), mutator: appMutator))
  }
}
