//
//  PomodoroState.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

public enum TimerType {
  case rest(duration: TimeInterval)
  case work(duration: TimeInterval)

  func toString() -> String {
    switch self {
    case .rest(duration: _):
      return "Break"
    case .work(duration: _):
      return "Work"
    }
  }

  var duration: TimeInterval {
    switch self {
    case let .rest(duration):
      return duration
    case let .work(duration):
      return duration
    }
  }
}

public struct TimerState {
  var defaultDuration: TimeInterval = TimeInterval(5)
  var breakDureation: TimeInterval = TimeInterval(3)
  var longBreakDuration: TimeInterval = TimeInterval(10)

  var cycles: [TimerType] = [
    .work(duration: 5),
    .rest(duration: 3),
    .work(duration: 5),
    .rest(duration: 3),
    .work(duration: 5),
    .rest(duration: 3),
    .work(duration: 5),
    .rest(duration: 8),
  ]

  var currentCycleIndex = 0

  var started: Date?
}

extension TimerState {
  var currentCycle: TimerType {
    return cycles[currentCycleIndex]
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
    state.currentCycleIndex = (state.currentCycleIndex + 1) % state.cycles.count
    return .empty()
  case .startTimer:
    state.started = Date()
    return .empty()
  case .stopTimer:
    state.started = nil
    return .empty()
  case .reset:
    state.started = nil
    state.currentCycleIndex = 0
    return .empty()
  }
}
