//
//  PomodoroState.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

struct TimerSettings {
  var workDuration: TimeInterval = 25 * 60
  var breakDuration: TimeInterval = 5 * 60
  var longBreakDuration: TimeInterval = 15 * 60
  var sessionCount = 4
}

public struct TimerState {
  var currentSession = 1
  var timerSettings: TimerSettings = TimerSettings()
  var started: Date?

  var currentDuration: TimeInterval {
    if currentSession == timerSettings.sessionCount {
      return timerSettings.longBreakDuration
    }
    return isBreak ? timerSettings.breakDuration : timerSettings.workDuration
  }

  var sessionText: String {
    if currentSession == timerSettings.sessionCount {
      return "Long Break"
    }
    return isBreak ? "Break" : "Work"
  }

  var isBreak: Bool {
    return currentSession % 2 == 0
  }
}

public enum TimerAction {
  case startTimer
  case stopTimer
  case advanceToNextRound
  case reset
}

public let timerReducer = Reducer<TimerState, TimerAction>.init { (state, action) -> Effect<TimerAction> in
  switch action {
  case .advanceToNextRound:
    state.started = nil
    state.currentSession = (state.currentSession % state.timerSettings.sessionCount) + 1
    return .empty()
  case .startTimer:
    state.started = CurrentTimerEnvironment.date()
    return .empty()
  case .stopTimer:
    state.started = nil
    return .empty()
  case .reset:
    state.started = nil
    state.currentSession = 1
    return .empty()
  }
}
