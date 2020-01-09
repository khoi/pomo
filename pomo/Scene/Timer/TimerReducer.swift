//
//  PomodoroState.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Combine
import Foundation

struct TimerSettings {
  var workDuration: TimeInterval = 25 * 60
  var breakDuration: TimeInterval = 5 * 60
  var longBreakDuration: TimeInterval = 15 * 60
  var sessionCount = 4
}

public struct TimerState {
  var currentSession = 1
  var timerSettings = TimerSettings()
  var started: Date?

  var timerRunning: Bool {
    started != nil
  }

  init(currentSession: Int = 1, timerSettings: TimerSettings = TimerSettings(), started: Date? = nil) {
    self.currentSession = currentSession
    self.timerSettings = timerSettings
    self.started = started
  }

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
    return isBreak ? "Break" : "Focus"
  }

  var isBreak: Bool {
    currentSession % 2 == 0
  }
}

enum TimerAction {
  case startTimer
  case stopTimer
  case completeCurrentSession
  case reset
  case loadTimerSettings
  case loadedTimerSettings(TimerSettings)
  case saveCurrentSession
  case loadCurrentSession
  case loadedCurrentSession(Int, Date?)
  case noop
}

let timerReducer = Reducer<TimerState, TimerAction> { (state, action) -> Effect<TimerAction> in
  switch action {
  case .completeCurrentSession:
    let currentSessionText = state.sessionText
    let currentDuration = state.currentDuration
    let started = state.started
    state.started = nil
    state.currentSession = (state.currentSession % state.timerSettings.sessionCount) + 1
    return CurrentTimerEnvironment
      .pomodoroRepository
      .saveTimer(started ?? CurrentTimerEnvironment.date(), currentDuration, currentSessionText)
      .map { _ in TimerAction.noop }
      .eraseToEffect()
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
  case .loadTimerSettings:
    return CurrentTimerEnvironment.timerSettingsRepository.load().map(TimerAction.loadedTimerSettings).eraseToEffect()
  case let .loadedTimerSettings(timerSettings):
    state.timerSettings = timerSettings
    return .empty()
  case .saveCurrentSession:
    return CurrentTimerEnvironment
      .timerSettingsRepository
      .saveCurrentSession(state.currentSession, state.started)
      .map { _ in TimerAction.noop }
      .eraseToEffect()
  case .loadCurrentSession:
    return CurrentTimerEnvironment.timerSettingsRepository.loadCurrentSession().map(TimerAction.loadedCurrentSession).eraseToEffect()
  case let .loadedCurrentSession(currentSession, started):
    state.started = started
    state.currentSession = currentSession
    return .empty()
  case .noop:
    return .empty()
  }
}
