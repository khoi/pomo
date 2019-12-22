//
//  HomeContainerView.swift
//  pomo
//
//  Created by khoi on 10/31/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct TimerContainer: View {
  @EnvironmentObject var store: Store<TimerState, TimerAction>

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
            self.store.send(TimerAction.reset)
          }) {
            Image(systemName: "arrow.counterclockwise")
              .font(.system(size: 30))
              .foregroundColor(Color("zima"))
          }
          .padding()
        }
        Spacer()
        VStack(spacing: 16) {
          Text(self.store.value.cycles[self.store.value.currentCycleIndex].toString())
            .font(.system(size: 30))
            .foregroundColor(Color("text"))

          Text(format(duration: self.timeLeft))
            .font(.system(size: 50))
            .foregroundColor(Color("text"))
            .padding()

          HStack {
            ForEach(0 ..< store.value.cycles.count) { i in
              Image(systemName: self.roundImageName(round: i, currentRound: self.store.value.currentCycleIndex))
                .font(.footnote)
            }
          }
          .padding()

          Button(action: {
            self.store.send(self.timerStarted ? TimerAction.stopTimer : TimerAction.startTimer)
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
            self.store.send(TimerAction.advanceToNextRound)
          }) {
            Image(systemName: "forward.end")
              .font(.system(size: 30))
              .foregroundColor(Color("zima"))
          }
          .padding()
        }
      }
      .onReceive(timer) { _ in
        guard let started = self.store.value.started else {
          self.timeLeft = self.store.value.currentCycle.duration
          return
        }
        let timeLeft = self.store.value.currentCycle.duration - Date().timeIntervalSince(started)
        if timeLeft <= 0 {
          self.store.send(TimerAction.advanceToNextRound)
          return
        }
        self.timeLeft = timeLeft
      }
    }
  }

  var timerStarted: Bool {
    store.value.started != nil
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

struct TimerContainerView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TimerContainer().environment(\.colorScheme, .light)
      TimerContainer().environment(\.colorScheme, .dark)
    }
    .environmentObject(Store<TimerState, TimerAction>(initialValue: TimerState(), reducer: timerReducer))
    .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
  }
}
