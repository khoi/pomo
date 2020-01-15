//
//  TimerReducerTests.swift
//  pomoTests
//
//  Created by khoi on 1/14/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import Combine
@testable import pomo
import XCTest

class TimerReducerTests: XCTestCase {
  override class func setUp() {
    CurrentTimerEnvironment = .mock
  }

  func testStartTimer() {
    CurrentTimerEnvironment.date = { Date(timeIntervalSince1970: 3000) }

    assert(
      initialValue: TimerState(started: nil),
      reducer: timerReducer,
      steps:
      Step(.send, .startTimer) {
        $0.started = Date(timeIntervalSince1970: 3000)
      }
    )
  }

  func testLoadTimerSettings() {
    let mockSettings = TimerSettings(workDuration: 5,
                                     breakDuration: 3,
                                     longBreakDuration: 5)
    CurrentTimerEnvironment.timerSettingsRepository.load = {
      .sync {
        mockSettings
      }
    }

    assert(
      initialValue: TimerState(started: nil),
      reducer: timerReducer,
      steps:
      Step(.send, .loadTimerSettings) { _ in },
      Step(.receive, .loadedTimerSettings(mockSettings)) { $0.timerSettings = mockSettings }
    )
  }

  func testResetTimer() {
    assert(
      initialValue: TimerState(currentSession: 3, started: Date()),
      reducer: timerReducer,
      steps:
      Step(.send, .reset) {
        $0.started = nil
        $0.currentSession = 1
      }
    )
  }
}
