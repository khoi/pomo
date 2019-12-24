//
//  HomeContainerView.swift
//  pomo
//
//  Created by khoi on 10/31/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import AVFoundation
import SwiftUI
import UIKit

struct TimerContainer: View {
  @EnvironmentObject var store: Store<TimerState, TimerAction>

  @State private var timeLeft: TimeInterval = 0
  @State private var showingStopConfirmationAlert = false
  @State private var showingResetConfirmationAlert = false
  @State private var showingSettingsModal = false

  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

  var body: some View {
    VStack {
      HStack {
        #if DEBUG
          Button(action: {
            self.showingSettingsModal.toggle()
          }) {
            Image(systemName: "gear")
              .font(.system(size: 30))
              .foregroundColor(Color("zima"))
          }
        #endif
        Spacer()
        Button(action: {
          self.showingResetConfirmationAlert.toggle()
        }) {
          Image(systemName: "arrow.counterclockwise")
            .font(.system(size: 30))
            .foregroundColor(Color("zima"))
        }
      }
      .padding()
      Spacer()
      VStack(spacing: 16) {
        Text(self.store.value.sessionText)
          .font(.system(size: 30))
          .foregroundColor(Color("text"))

        Text(format(duration: self.timeLeft))
          .font(.system(size: 50))
          .foregroundColor(Color("text"))
          .padding()

        HStack(alignment: .center, spacing: 16) {
          ForEach(1 ..< self.store.value.timerSettings.sessionCount + 1) { i in
            ZStack {
              if i < self.store.value.currentSession {
                Circle()
              } else if i == self.store.value.currentSession {
                Circle()
                  .stroke(style: StrokeStyle(lineWidth: 1))
                Circle()
                  .trim(from: 0, to: self.currentProgress)
                  .rotationEffect(.degrees(-90))
              } else {
                Circle().stroke(style: StrokeStyle(lineWidth: 1))
              }
            }.frame(width: 10, height: 10, alignment: .center)
          }
        }
        .padding()

        Button(action: {
          guard !self.store.value.timerRunning else {
            self.showingStopConfirmationAlert = true
            return
          }
          self.store.send(self.store.value.timerRunning ? TimerAction.stopTimer : TimerAction.startTimer)
        }) {
          Image(systemName: store.value.timerRunning ? "stop" : "play")
            .font(.system(size: 50))
            .foregroundColor(Color("zima"))
        }
        .padding()
      }
      Spacer()

      HStack {
        Spacer()
        Button(action: {
          self.store.send(TimerAction.completeCurrentSession)
        }) {
          Image(systemName: "forward.end")
            .font(.system(size: 30))
            .foregroundColor(Color("zima"))
        }
        .padding()
      }
    }
    .background(Color("background"))
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
    .alert(isPresented: $showingStopConfirmationAlert) {
      Alert(title: Text("Sure?"), message: Text("This will reset your current session"), primaryButton: .destructive(Text("Stop"), action: {
        self.store.send(.stopTimer)
        self.showingStopConfirmationAlert.toggle()
      }), secondaryButton: .cancel())
    }
    .alert(isPresented: $showingResetConfirmationAlert) {
      Alert(title: Text("Sure?"), message: Text("This will reset all current sessions"), primaryButton: .destructive(Text("Reset"), action: {
        self.store.send(.reset)
        self.showingResetConfirmationAlert.toggle()
      }), secondaryButton: .cancel())
    }
    .sheet(isPresented: $showingSettingsModal, onDismiss: {
      self.store.send(.loadTimerSettings)
    }) {
      SettingsView()
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

struct TimerContainerView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TimerContainer().environment(\.colorScheme, .light).environmentObject(Store<TimerState, TimerAction>(initialValue: TimerState(currentSession: 2), reducer: timerReducer))
      TimerContainer().environment(\.colorScheme, .dark).environmentObject(Store<TimerState, TimerAction>(initialValue: TimerState(currentSession: 3), reducer: timerReducer))
    }

    .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
  }
}
