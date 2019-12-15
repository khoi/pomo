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
      Color("background")
        .edgesIgnoringSafeArea(.all)
      VStack {
        HStack {
          Spacer()
          Button(action: {
            self.store.dispatch(AppAction.reset)
          }) {
            Image(systemName: "arrow.counterclockwise")
              .font(.system(size: 30))
              .foregroundColor(Color("zima"))
          }
          .padding()
        }
        Spacer()
        VStack(spacing: 16) {
          Text("Work")
            .font(.system(size: 30))
            .foregroundColor(Color("text"))

          Text(format(duration: self.timeLeft))
            .font(.system(size: 50))
            .foregroundColor(Color("text"))
            .padding()

          HStack {
            ForEach(1 ..< store.state.totalRound + 1) { i in
              Image(systemName: self.roundImageName(round: i, currentRound: self.store.state.currentRound))
                .font(.footnote)
            }
          }
          .padding()

          Button(action: {
            self.store.dispatch(self.timerStarted ? AppAction.stopTimer : AppAction.startTimer)
          }) {
            Image(systemName: self.timerStarted ? "stop" : "play")
              .font(.system(size: 50))
              .foregroundColor(Color("zima"))
          }
          .padding()
        }
        Spacer()
        HStack {
          Spacer()
          Button(action: {
            self.store.dispatch(AppAction.skip)
          }) {
            Image(systemName: "forward.end")
              .font(.system(size: 30))
              .foregroundColor(Color("zima"))
          }
          .padding()
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

  func roundImageName(round: Int, currentRound: Int) -> String {
    if round == currentRound {
      return "smallcircle.fill.circle"
    }
    return round < currentRound ? "circle.fill" : "circle"
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
    Group {
      HomeContainer().environment(\.colorScheme, .light)
      HomeContainer().environment(\.colorScheme, .dark)
    }
    .environmentObject(Store<AppState, AppMutation>(state: AppState(), mutator: appMutator))
    .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
  }
}
