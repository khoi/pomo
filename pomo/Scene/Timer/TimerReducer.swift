//
//  PomodoroState.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Combine
import ComposableArchitecture
import Foundation

public struct TimerSettings: Equatable {
  var workDuration: TimeInterval = 25 * 60
  var breakDuration: TimeInterval = 5 * 60
  var longBreakDuration: TimeInterval = 15 * 60
  var sessionCount = 4
  var soundEnabled = false
}

public struct TimerState: Equatable {
  var currentSession: Int
  var timerSettings: TimerSettings
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

public enum TimerAction: Equatable {
  case startTimer
  case stopTimer
  case completeCurrentSession
  case reset
  case saveCurrentSession
  case loadTimerSettings
  case loadedTimerSettings(TimerSettings)
  case saveTimerSettings(TimerSettings)
  case loadCurrentSession
  case loadedCurrentSession(Int, Date?)
}

func timerReducer(
  state: inout TimerState,
  action: TimerAction,
  environment: TimerEnvironment
) -> Effect<TimerAction> {
  switch action {
  case .completeCurrentSession:
    let currentSessionText = state.sessionText
    let currentDuration = state.currentDuration
    let started = state.started

    state.started = nil
    state.currentSession = (state.currentSession % state.timerSettings.sessionCount) + 1
    let startedDate = started ?? environment.date()
    let localState = state

    let saveTimerEffect = environment.pomodoroRepository.saveTimer(startedDate, currentDuration, currentSessionText)
    let playSoundEffect = localState.timerSettings.soundEnabled ? environment.hapticHandler.playSound() : .empty()

    return Publishers.MergeMany([
      saveTimerEffect,
      playSoundEffect,
    ])
      .fireAndForget()
  case .startTimer:
    state.started = environment.date()
    return environment
      .hapticHandler
      .impactOccurred()
      .fireAndForget()
  case .stopTimer:
    state.started = nil
    return environment
      .hapticHandler
      .impactOccurred()
      .fireAndForget()
  case .reset:
    state.started = nil
    state.currentSession = 1
    return .empty()
  case let .saveTimerSettings(settings):
    return environment
      .timerSettingsRepository
      .save(settings)
      .fireAndForget()
  case .loadTimerSettings:
    return environment
      .timerSettingsRepository
      .load()
      .map(TimerAction.loadedTimerSettings)
      .eraseToEffect()
  case let .loadedTimerSettings(timerSettings):
    state.timerSettings = timerSettings
    return .empty()
  case .saveCurrentSession:
    return environment
      .timerSettingsRepository
      .saveCurrentSession(state.currentSession, state.started)
      .fireAndForget()
  case .loadCurrentSession:
    return environment
      .timerSettingsRepository
      .loadCurrentSession()
      .map(TimerAction.loadedCurrentSession)
      .eraseToEffect()
  case let .loadedCurrentSession(currentSession, started):
    state.started = started
    state.currentSession = currentSession
    return .empty()
  }
}
