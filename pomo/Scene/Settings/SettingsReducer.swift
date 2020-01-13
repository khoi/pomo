//
//  SettingsReducer.swift
//  pomo
//
//  Created by Danh Dang on 1/5/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import Foundation

enum SettingsAction {
    case saveTimerSettings(TimerSettings)
    case noop
}

let settingsReducer = Reducer<TimerSettings, SettingsAction> { (_, action) -> Effect<SettingsAction> in
    switch action {
    case let .saveTimerSettings(newTimerSettings):
        return CurrentTimerEnvironment
            .timerSettingsRepository
            .save(newTimerSettings)
            .map { _ in SettingsAction.noop }
            .eraseToEffect()
    default:
        return .empty()
    }
}
