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

  func testStopTimer() {
    assert(
      initialValue: TimerState(started: Date()),
      reducer: timerReducer,
      steps:
      Step(.send, .stopTimer) {
        $0.started = nil
      }
    )
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

  func testLoadCurrentSession() {
    let currentSession = (currentSession: 3, started: Date())
    CurrentTimerEnvironment.timerSettingsRepository.loadCurrentSession = {
      .sync {
        currentSession
      }
    }

    assert(
      initialValue: TimerState(started: nil),
      reducer: timerReducer,
      steps:
      Step(.send, .loadCurrentSession) { _ in },
      Step(.receive, .loadedCurrentSession(currentSession.currentSession, currentSession.started)) {
        $0.started = currentSession.started
        $0.currentSession = currentSession.currentSession
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

  func testSaveCurrentSession() {
    var didSave = false
    CurrentTimerEnvironment.timerSettingsRepository.saveCurrentSession = { _, _ in
      .fireAndForget {
        didSave = true
      }
    }

    let state = TimerState()
    var expected = state

    _ = timerReducer.reduce(&expected, .saveCurrentSession).sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssertEqual(state, expected)
    XCTAssert(didSave)
  }

  func testNoOp() {
    assert(
      initialValue: TimerState(),
      reducer: timerReducer,
      steps:
      Step(.send, .noop) { _ in }
    )
  }
}
