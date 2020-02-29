//
//  SettingsReducer.swift
//  pomo
//
//  Created by Danh Dang on 1/5/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import Foundation

public enum SettingsAction {
  case saveTimerSettings(TimerSettings)
}

public func settingsReducer(
  state _: inout TimerSettings,
  action: SettingsAction
) -> Effect<SettingsAction> {
  switch action {
  case let .saveTimerSettings(newTimerSettings):
    return CurrentTimerEnvironment
      .timerSettingsRepository
      .save(newTimerSettings)
      .fireAndForget()
  }
}
