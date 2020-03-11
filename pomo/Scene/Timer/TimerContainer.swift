//
//  HomeContainerView.swift
//  pomo
//
//  Created by khoi on 10/31/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import AVFoundation
import ComposableArchitecture
import SwiftUI
import UIKit

struct TimerContainer: View {
  @ObservedObject var store: Store<TimerState, TimerAction>

  @State private var timeLeft: TimeInterval = 0
  @State private var showingStopConfirmationAlert = false
  @State private var showingResetConfirmationAlert = false
  @State private var showingNextConfirmationAlert = false

  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

  let openStatistic: () -> Void
  let openSettings: () -> Void

  var body: some View {
    VStack {
      HStack {
        Button(action: openSettings) {
          Image(systemName: "gear")
            .font(.system(size: 30))
            .foregroundColor(Color("zima"))
        }
        Spacer()
        Button(action: {
          self.showingResetConfirmationAlert.toggle()
        }) {
          Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 30))
            .foregroundColor(Color("zima"))
        }
        .alert(isPresented: $showingResetConfirmationAlert) {
          Alert(title: Text("Sure?"), message: Text("This will reset all current sessions"), primaryButton: .destructive(Text("Reset"), action: {
            self.store.send(.reset)
            self.showingResetConfirmationAlert.toggle()
          }), secondaryButton: .cancel())
        }
      }
      .padding()
      Spacer()
      VStack(spacing: 16) {
        Text(self.store.value.sessionText)
          .font(.system(size: 30))
          .foregroundColor(Color(.label))

        Text(format(duration: self.timeLeft))
          .font(Font.system(size: 50, weight: .medium, design: .rounded).monospacedDigit())
          .foregroundColor(Color(.label))
          .padding()

        HStack(alignment: .center, spacing: 16) {
          ForEach(1 ..< self.store.value.timerSettings.sessionCount + 1) { i in
            ZStack {
              if i < self.store.value.currentSession {
                Circle()
              } else if i == self.store.value.currentSession {
                Circle()
                  .stroke(style: StrokeStyle(lineWidth: 1))
                CircleProgressView(progress: Double(self.currentProgress))
              } else {
                Circle().stroke(style: StrokeStyle(lineWidth: 1))
              }
            }
            .frame(width: 10, height: 10, alignment: .center)
          }
        }
        .padding()

        Button(action: {
          if self.store.value.timerRunning {
            self.showingStopConfirmationAlert = true
          } else {
            self.store.send(TimerAction.startTimer)
          }
        }) {
          Image(systemName: store.value.timerRunning ? "stop" : "play")
            .font(.system(size: 50))
            .foregroundColor(Color("zima"))
        }
        .padding()
        .alert(isPresented: $showingStopConfirmationAlert) {
          Alert(title: Text("Sure?"), message: Text("This will reset your current session"), primaryButton: .destructive(Text("Stop"), action: {
            self.store.send(.stopTimer)
            self.showingStopConfirmationAlert.toggle()
          }), secondaryButton: .cancel())
        }
      }
      Spacer()

      HStack {
        if self.store.value.isBreak {
          Button(action: {
            self.showingNextConfirmationAlert = true
          }) {
            Image(systemName: "forward.end")
              .font(.system(size: 30))
              .foregroundColor(Color("zima"))
          }
          .padding()
          .alert(isPresented: $showingNextConfirmationAlert) {
            Alert(title: Text("Sure?"), message: Text("This will skip the break"), primaryButton: .destructive(Text("Next"), action: {
              self.store.send(TimerAction.completeCurrentSession)
            }), secondaryButton: .cancel())
          }
        }
        Spacer()
        Button(action: openStatistic) {
          Image(systemName: "chart.bar")
            .font(.system(size: 30))
            .foregroundColor(Color("zima"))
        }
        .padding()
      }
    }
    .background(Color(.systemBackground))
    .onReceive(timer) { _ in
      guard let started = self.store.value.started else {
        self.timeLeft = self.store.value.currentDuration
        return
      }
      let timeLeft = self.store.value.currentDuration - Date().timeIntervalSince(started)
      if timeLeft <= 0 {
        self.store.send(TimerAction.completeCurrentSession)
        return
      }
      self.timeLeft = timeLeft
      UIApplication.shared.isIdleTimerDisabled = self.store.value.timerRunning
    }
    .onAppear {
      self.store.send(.loadTimerSettings)
    }
  }

  var currentProgress: CGFloat {
    guard store.value.timerRunning else {
      return 0
    }
    return CGFloat((store.value.currentDuration - timeLeft) / store.value.currentDuration)
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

#if DEBUG
  struct TimerContainerView_Previews: PreviewProvider {
    static let store = Store<TimerState, TimerAction>(
      initialValue: TimerState(
        currentSession: 1,
        timerSettings: TimerSettings(workDuration: 5, breakDuration: 5, longBreakDuration: 5, sessionCount: 4),
        started: Date(timeIntervalSince1970: 1_577_528_235)
      ),
      reducer: timerReducer,
      environment: TimerEnvironment(
        date: Date.init,
        timerSettingsRepository: .mock,
        pomodoroRepository: .mock,
        hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
      )
    )
    static var previews: some View {
      Group {
        TimerContainer(store: store, openStatistic: {}, openSettings: {}).environment(\.colorScheme, .light)
        TimerContainer(store: store, openStatistic: {}, openSettings: {}).environment(\.colorScheme, .dark)
      }
      .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
    }
  }
#endif
