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
}

let appReducer = combine(
  pullback(timerReducer, value: \AppState.timer, action: /AppAction.timer),
  pullback(statisticReducer, value: \AppState.statistic, action: /AppAction.statistic),
  pullback(settingsReducer, value: \AppState.timer.timerSettings, action: /AppAction.settings)
)
