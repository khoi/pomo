//
//  PomodoroState.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

public struct TimerState {
  var defaultDuration: TimeInterval = TimeInterval(5)
  var breakDureation: TimeInterval = TimeInterval(3)
  var longBreakDuration: TimeInterval = TimeInterval(10)

  var started: Date?
  var activityLogs = [String]()

  var currentRound = 1
  var totalRound = 8 // including breaks

  var currentWorkingRound: Int {
    (currentRound + 1) / 2
  }

  var workingRounds: Int {
    totalRound / 2
  }

  var isBreak: Bool {
    currentRound % 2 == 0
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
    state.currentRound = state.currentRound == state.totalRound ? 1 :
      state.currentRound + 1
    return .empty()
  case .startTimer:
    state.started = Date()
    return .empty()
  case .stopTimer:
    state.started = nil
    return .empty()
  case .reset:
    state.started = nil
    state.currentRound = 1
    return .empty()
  }
}
