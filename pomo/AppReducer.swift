//
//  AppReducer.swift
//  pomo
//
//  Created by khoi on 12/27/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import CasePaths
import ComposableArchitecture
import Foundation

struct AppState {
  var timer = TimerState()
  var statistic = StatisticState()
}

enum AppAction {
  case timer(TimerAction)
  case statistic(StatisticAction)
}

typealias AppEnvironment = (
  date: () -> Date,
  timerSettingsRepository: TimerSettingsRepository,
  pomodoroRepository: PomodoroRepository,
  hapticHandler: TimerHapticHandler,
  loadStatistic: () -> Effect<Statistic>
)

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
  pullback(
    timerReducer,
    value: \AppState.timer,
    action: /AppAction.timer,
    environment: { TimerEnvironment($0.date, $0.timerSettingsRepository, $0.pomodoroRepository, $0.hapticHandler) }
  ),
  pullback(
    statisticReducer,
    value: \AppState.statistic,
    action: /AppAction.statistic,
    environment: { StatisticEnvironment($0.date, $0.loadStatistic) }
  )
)
