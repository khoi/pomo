//
//  AppReducer.swift
//  pomo
//
//  Created by khoi on 12/27/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import CasePaths
import Foundation

struct AppState {
  var timer = TimerState()
  var statistic = StatisticState()
}

enum AppAction {
  case timer(TimerAction)
  case statistic(StatisticAction)
  case settings(SettingsAction)

  var timer: TimerAction? {
    get {
      guard case let .timer(value) = self else { return nil }
      return value
    }
    set {
      guard case .timer = self, let newValue = newValue else { return }
      self = .timer(newValue)
    }
  }

  var statistic: StatisticAction? {
    get {
      guard case let .statistic(value) = self else { return nil }
      return value
    }
    set {
      guard case .statistic = self, let newValue = newValue else { return }
      self = .statistic(newValue)
    }
  }

  var settings: SettingsAction? {
    get {
      guard case let .settings(value) = self else { return nil }
      return value
    }
    set {
      guard case .settings = self, let newValue = newValue else { return }
      self = .settings(newValue)
    }
  }
}

let appReducer = combine(
  pullback(timerReducer, value: \AppState.timer, action: /AppAction.timer),
  pullback(statisticReducer, value: \AppState.statistic, action: /AppAction.statistic),
  pullback(settingsReducer, value: \AppState.timer.timerSettings, action: /AppAction.settings)
)
