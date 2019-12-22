//
//  TimerEnvironment.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

struct TimerSettingsRepository {
  var load: () -> Effect<TimerSettings>
  var save: (TimerSettings) -> Effect<Never>
  var saveCurrentSession: (_ currentSession: Int, _ started: Date?) -> Effect<Never>
  var loadCurrentSession: () -> Effect<(currentSession: Int, started: Date?)>
}

extension TimerSettingsRepository {
  static let live = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
    .sync {
      TimerSettings(workDuration: UserDefaultsSettings.workDuration,
                    breakDuration: UserDefaultsSettings.breakDuration,
                    longBreakDuration: UserDefaultsSettings.longBreakDuration)
    }
  }, save: { (settings) -> Effect<Never> in
    .fireAndForget {
      UserDefaultsSettings.workDuration = settings.workDuration
      UserDefaultsSettings.breakDuration = settings.breakDuration
      UserDefaultsSettings.longBreakDuration = settings.longBreakDuration
      UserDefaultsSettings.sessionCount = settings.sessionCount
    }
  }, saveCurrentSession: { currentSession, started in
    .fireAndForget {
      UserDefaultsSettings.currentSession = currentSession
      UserDefaultsSettings.sessionStarted = started
    }
  }, loadCurrentSession: {
    .sync { () -> (currentSession: Int, started: Date?) in
      (UserDefaultsSettings.currentSession, UserDefaultsSettings.sessionStarted)
    }
  })
}

public struct TimerEnvironment {
  var date: () -> Date = Date.init
  var timerSettingsRepository: TimerSettingsRepository = .live
}

extension TimerEnvironment {
  static let live = TimerEnvironment()
}

var CurrentTimerEnvironment = TimerEnvironment.live
