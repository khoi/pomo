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
      TimerSettings(workDuration: AppSettings.workDuration,
                    breakDuration: AppSettings.breakDuration,
                    longBreakDuration: AppSettings.longBreakDuration,
                    soundEnabled: AppSettings.isSoundEnabled)
    }
  }, save: { (settings) -> Effect<Never> in
    .fireAndForget {
      AppSettings.workDuration = settings.workDuration
      AppSettings.breakDuration = settings.breakDuration
      AppSettings.longBreakDuration = settings.longBreakDuration
      AppSettings.sessionCount = settings.sessionCount
      AppSettings.isSoundEnabled = settings.soundEnabled
    }
  }, saveCurrentSession: { currentSession, started in
    .fireAndForget {
      AppSettings.currentSession = currentSession
      AppSettings.sessionStarted = started
    }
  }, loadCurrentSession: {
    .sync { () -> (currentSession: Int, started: Date?) in
      (AppSettings.currentSession, AppSettings.sessionStarted)
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

struct TimerHapticHandler {
  private let provider: HapticProvider
  var impactOccurred: () -> Effect<Never>
  var playSound: () -> Effect<Never>

  init(provider: HapticProvider) {
    self.provider = provider
    impactOccurred = {
      provider.impactOccured()
    }

    playSound = {
      provider.playSound()
    }
  }
}

extension TimerHapticHandler {
  static let live = TimerHapticHandler(provider: iOSHapticProvider())
}

public struct TimerEnvironment {
  var date: () -> Date = Date.init
  var timerSettingsRepository: TimerSettingsRepository = .live
  var pomodoroRepository: PomodoroRepository = .live
  var hapticHandler: TimerHapticHandler = .live
}

extension TimerEnvironment {
  static let live = TimerEnvironment()
}

extension TimerState {
  static let live = TimerState()
}

var CurrentTimerEnvironment = TimerEnvironment.live

#if DEBUG
  extension TimerEnvironment {
    static let mock = TimerEnvironment(
      date: { Date(timeIntervalSince1970: 1_577_528_238) },
      timerSettingsRepository: .mock,
      pomodoroRepository: .mock,
      hapticHandler: .mock
    )
  }

  extension TimerSettingsRepository {
    static let mock = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      .sync {
        TimerSettings(workDuration: 5,
                      breakDuration: 3,
                      longBreakDuration: 5)
      }
    }, save: { (_) -> Effect<Never> in
      .empty()
    }, saveCurrentSession: { _, _ in
      .empty()
    }, loadCurrentSession: {
      .sync { () -> (currentSession: Int, started: Date?) in
        (1, nil)
      }
  })
  }

  extension PomodoroRepository {
    static let mock = PomodoroRepository { (_, _, _) -> Effect<Never> in
      .fireAndForget {}
    }
  }

  extension TimerHapticHandler {
    static let mock = TimerHapticHandler(provider: ConsoleHapticProvider())
  }
#endif
