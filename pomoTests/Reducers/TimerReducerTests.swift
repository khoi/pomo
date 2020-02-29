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

  func testCompleteSession() {
    let mockSettings = TimerSettings(sessionCount: 4)
    CurrentTimerEnvironment.timerSettingsRepository.load = {
      .sync {
        mockSettings
      }
    }

    assert(
      initialValue: TimerState(currentSession: 1, started: Date(timeIntervalSince1970: 3000)),
      reducer: timerReducer,
      steps:
      .send(.completeCurrentSession) {
        $0.currentSession = 2
        $0.started = nil
      },
      .send(.completeCurrentSession) {
        $0.currentSession = 3
        $0.started = nil
      },
      .send(.completeCurrentSession) {
        $0.currentSession = 4
        $0.started = nil
      }
    )
  }

  func testCompleteAllPomodoros() {
    let mockSettings = TimerSettings(sessionCount: 4)
    CurrentTimerEnvironment.timerSettingsRepository.load = {
      .sync {
        mockSettings
      }
    }
    assert(
      initialValue: TimerState(currentSession: 4, started: Date(timeIntervalSince1970: 3000)),
      reducer: timerReducer,
      steps:
      .send(.completeCurrentSession) {
        $0.currentSession = 1
        $0.started = nil
      }
    )
  }

  func testAllPomodorosHappyFlow() {
    CurrentTimerEnvironment.date = { Date(timeIntervalSince1970: 3000) }
    CurrentTimerEnvironment.timerSettingsRepository.load = {
      .sync {
        TimerSettings(sessionCount: 4)
      }
    }

    assert(
      initialValue: TimerState(currentSession: 1, started: nil),
      reducer: timerReducer,
      steps:
      .send(.startTimer) {
        $0.started = Date(timeIntervalSince1970: 3000)
      },
      .send(.completeCurrentSession) {
        $0.currentSession = 2
        $0.started = nil
      },
      .send(.completeCurrentSession) {
        $0.currentSession = 3
        $0.started = nil
      },
      .send(.completeCurrentSession) {
        $0.currentSession = 4
        $0.started = nil
      },
      .send(.completeCurrentSession) {
        $0.currentSession = 1
        $0.started = nil
      }
    )
  }

  func testStopTimer() {
    assert(
      initialValue: TimerState(started: Date()),
      reducer: timerReducer,
      steps:
      .send(.stopTimer) {
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
      .send(.startTimer) {
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
      .send(.loadCurrentSession) { _ in },
      .receive(.loadedCurrentSession(currentSession.currentSession, currentSession.started)) {
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
      .send(.loadTimerSettings) { _ in },
      .receive(.loadedTimerSettings(mockSettings)) { $0.timerSettings = mockSettings }
    )
  }

  func testResetTimer() {
    assert(
      initialValue: TimerState(currentSession: 3, started: Date()),
      reducer: timerReducer,
      steps:
      .send(.reset) {
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

    _ = timerReducer(state: &expected, action: .saveCurrentSession).sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssertEqual(state, expected)
    XCTAssert(didSave)
  }

  func testTriggerSound() {
    var didTriggerSound = false
    CurrentTimerEnvironment.hapticHandler.playSound = {
      .fireAndForget {
        didTriggerSound = true
      }
    }

    var state = TimerState()
    state.timerSettings.soundEnabled = true

    _ = timerReducer(state: &state, action: .completeCurrentSession).sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssert(didTriggerSound)
  }

  func testShouldNotTriggerSound() {
    var didTriggerSound = false
    CurrentTimerEnvironment.hapticHandler.playSound = {
      .fireAndForget {
        didTriggerSound = true
      }
    }

    var state = TimerState()

    _ = timerReducer(state: &state, action: .completeCurrentSession).sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssertFalse(didTriggerSound)
  }

  func testShouldTriggerHapticFeedbackWhenStartTimer() {
    var didTriggerHapticFeedback = false
    CurrentTimerEnvironment.hapticHandler.impactOccurred = {
      .fireAndForget {
        didTriggerHapticFeedback = true
      }
    }

    var state = TimerState()

    _ = timerReducer(state: &state, action: .startTimer).sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssert(didTriggerHapticFeedback)
  }

  func testShouldTriggerHapticFeedbackWhenStopTimer() {
    var didTriggerHapticFeedback = false
    CurrentTimerEnvironment.hapticHandler.impactOccurred = {
      .fireAndForget {
        didTriggerHapticFeedback = true
      }
    }

    var state = TimerState()

    _ = timerReducer(state: &state, action: .stopTimer).sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssert(didTriggerHapticFeedback)
  }
}
