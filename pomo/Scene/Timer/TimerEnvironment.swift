//
//  TimerEnvironment.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import CoreData
import Foundation
import os.log
import UIKit

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

struct PomodoroRepository {
  var saveTimer: (_ started: Date, _ duration: TimeInterval, _ text: String) -> Effect<Never>
}

extension PomodoroRepository {
  static let live = PomodoroRepository.init { (started, duration, text) -> Effect<Never> in
    .fireAndForget {
      let persistenceContainer = CoreDataStack.shared.persistentContainer
      persistenceContainer.performBackgroundTask { context in
        let p = Pomodoro(context: context)
        p.duration = duration
        p.text = text
        p.uuid = UUID()
        p.started = started
        do {
          try context.save()
        } catch {
          os_log("can't save pomo to cloudkit %{public}@", error.localizedDescription)
        }
      }
    }
  }
}

public struct TimerEnvironment {
  var date: () -> Date = Date.init
  var timerSettingsRepository: TimerSettingsRepository = .live
  var pomodoroRepository: PomodoroRepository = .live
}

extension TimerEnvironment {
  static let live = TimerEnvironment()
}

var CurrentTimerEnvironment = TimerEnvironment.live
