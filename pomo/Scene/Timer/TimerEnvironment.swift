//
//  TimerEnvironment.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

public struct TimerSettingsRepository {
  var load: () -> Effect<[TimerType]>
}

extension TimerSettingsRepository {
  static var live = TimerSettingsRepository { () -> Effect<[TimerType]> in
    .sync {
      (0 ..< UserDefaultsSettings.sessionCount).flatMap {
        [
          .work(duration: UserDefaultsSettings.workDuration),
          .break(duration: $0 == UserDefaultsSettings.sessionCount - 1 ? UserDefaultsSettings.longBreakDuration : UserDefaultsSettings.breakDuration),
        ]
      }
    }
  }
}

#if DEBUG
  extension TimerSettingsRepository {
    static var mock = TimerSettingsRepository { () -> Effect<[TimerType]> in
      .sync { [
        .work(duration: 5),
        .break(duration: 3),
        .work(duration: 5),
        .break(duration: 3),
        .work(duration: 5),
        .break(duration: 3),
        .work(duration: 5),
        .break(duration: 5),
      ]
      }
    }
  }
#endif

public struct TimerEnvironment {
  var date: () -> Date = Date.init
  var timerSettingsRepo: TimerSettingsRepository = .live
}

extension TimerEnvironment {
  static let live = TimerEnvironment()
}

var CurrentTimerEnvironment = TimerEnvironment.live
