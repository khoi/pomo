//
//  AppReducer.swift
//  pomo
//
//  Created by khoi on 12/27/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

struct AppState {
  var timer = CurrentTimerEnvironment.timerState
  var statistic = StatisticState()
}

enum AppAction {
  case timer(TimerAction)
  case statistic(StatisticAction)

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
}

let appReducer = combine(
  pullback(withSoundsAndVibrations(reducer: timerReducer), value: \AppState.timer, action: \AppAction.timer),
  pullback(statisticReducer, value: \AppState.statistic, action: \AppAction.statistic)
)
