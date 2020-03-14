//
//  TimerReducerTests.swift
//  pomoTests
//
//  Created by khoi on 1/14/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import Combine
import ComposableArchitecture
@testable import pomo
import XCTest

class TimerReducerTests: XCTestCase {
  func testCompleteSession() {
    let mockSettings = TimerSettings(sessionCount: 4)
    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      .sync { mockSettings }
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }
    let mockEnv = TimerEnvironment(
      date: Date.init,
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(currentSession: 1, started: Date(timeIntervalSince1970: 3000)),
      reducer: timerReducer,
      environment: mockEnv,
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
    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      .sync { mockSettings }
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }
    let mockEnv = TimerEnvironment(
      date: Date.init,
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(currentSession: 4, started: Date(timeIntervalSince1970: 3000)),
      reducer: timerReducer,
      environment: mockEnv,
      steps:
      .send(.completeCurrentSession) {
        $0.currentSession = 1
        $0.started = nil
      }
    )
  }

  func testAllPomodorosHappyFlow() {
    let mockSettings = TimerSettings(sessionCount: 4)

    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      .sync { mockSettings }
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: { Date(timeIntervalSince1970: 3000) },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(currentSession: 1, started: nil),
      reducer: timerReducer,
      environment: mockEnvironment,
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
    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: { Date(timeIntervalSince1970: 3000) },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(started: Date()),
      reducer: timerReducer,
      environment: mockEnvironment,
      steps:
      .send(.stopTimer) {
        $0.started = nil
      }
    )
  }

  func testStartTimer() {
    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: { Date(timeIntervalSince1970: 3000) },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(started: nil),
      reducer: timerReducer,
      environment: mockEnvironment,
      steps:
      .send(.startTimer) {
        $0.started = Date(timeIntervalSince1970: 3000)
      }
    )
  }

  func testLoadCurrentSession() {
    let currentSession = (currentSession: 3, started: Date())

    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      .sync { currentSession }
    }

    let mockEnvironment = TimerEnvironment(
      date: { Date(timeIntervalSince1970: 3000) },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(started: nil),
      reducer: timerReducer,
      environment: mockEnvironment,
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

    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      .sync { mockSettings }
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: { Date(timeIntervalSince1970: 3000) },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(started: nil),
      reducer: timerReducer,
      environment: mockEnvironment,
      steps:
      .send(.loadTimerSettings) { _ in },
      .receive(.loadedTimerSettings(mockSettings)) { $0.timerSettings = mockSettings }
    )
  }

  func testResetTimer() {
    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: { fatalError() },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(currentSession: 3, started: Date()),
      reducer: timerReducer,
      environment: mockEnvironment,
      steps:
      .send(.reset) {
        $0.started = nil
        $0.currentSession = 1
      }
    )
  }

  func testSaveCurrentSession() {
    var didSave = false
    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      .fireAndForget {
        didSave = true
      }
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: { fatalError() },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    let state = TimerState()
    var expected = state

    _ = timerReducer(state: &expected, action: .saveCurrentSession, environment: mockEnvironment).sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssertEqual(state, expected)
    XCTAssert(didSave)
  }

  func testTriggerSound() {
    var didTriggerSound = false

    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: Date.init,
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: .init(
        impactOccurred: { fatalError() },
        playSound: { () -> Effect<Never> in
          .fireAndForget {
            didTriggerSound = true
          }
        }
      )
    )

    var state = TimerState()
    state.timerSettings.soundEnabled = true

    _ = timerReducer(
      state: &state,
      action: .completeCurrentSession,
      environment: mockEnvironment
    )
    .sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssert(didTriggerSound)
  }

  func testShouldNotTriggerSound() {
    var didTriggerSound = false

    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: Date.init,
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: .init(
        impactOccurred: { fatalError() },
        playSound: { () -> Effect<Never> in
          .fireAndForget {
            didTriggerSound = true
          }
        }
      )
    )

    var state = TimerState()
    state.timerSettings.soundEnabled = false

    _ = timerReducer(
      state: &state,
      action: .completeCurrentSession,
      environment: mockEnvironment
    )
    .sink(receiveValue: { _ in
      XCTFail("No action expected")
    })

    XCTAssertFalse(didTriggerSound)
  }

  func testShouldTriggerHapticFeedbackWhenStartTimer() {
    var didTriggerHapticFeedback = false

    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: Date.init,
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: .init(
        impactOccurred: { .fireAndForget {
          didTriggerHapticFeedback = true
        } },
        playSound: { fatalError()
        }
      )
    )

    var state = TimerState()

    _ = timerReducer(state: &state, action: .startTimer, environment: mockEnvironment)
      .sink(receiveValue: { _ in
        XCTFail("No action expected")
      })

    XCTAssert(didTriggerHapticFeedback)
  }

  func testShouldTriggerHapticFeedbackWhenStopTimer() {
    var didTriggerHapticFeedback = false

    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      fatalError()
    }, save: { (_) -> Effect<Never> in
      fatalError()
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
    }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: { fatalError() },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: .init(
        impactOccurred: { .fireAndForget {
          didTriggerHapticFeedback = true
        } },
        playSound: { fatalError()
        }
      )
    )

    var state = TimerState()

    _ = timerReducer(state: &state, action: .stopTimer, environment: mockEnvironment)
      .sink(receiveValue: { _ in
        XCTFail("No action expected")
      })

    XCTAssert(didTriggerHapticFeedback)
  }

  func testSaveTimerSettings() {
    var savedSettings: TimerSettings?
    let mockSettings = TimerSettings(workDuration: 5,
                                     breakDuration: 3,
                                     longBreakDuration: 5)

    let mockRepository = TimerSettingsRepository(load: { () -> Effect<TimerSettings> in
      .sync { savedSettings! }
    }, save: { newSettings -> Effect<Never> in
      .fireAndForget { savedSettings = newSettings }
    }, saveCurrentSession: { (_, _) -> Effect<Never> in
      fatalError()
      }) { () -> Effect<(currentSession: Int, started: Date?)> in
      fatalError()
    }

    let mockEnvironment = TimerEnvironment(
      date: { Date(timeIntervalSince1970: 3000) },
      timerSettingsRepository: mockRepository,
      pomodoroRepository: .mock,
      hapticHandler: TimerHapticHandler(provider: ConsoleHapticProvider())
    )

    assert(
      initialValue: TimerState(started: nil),
      reducer: timerReducer,
      environment: mockEnvironment,
      steps:
      .send(.saveTimerSettings(mockSettings)) { _ in },
      .send(.loadTimerSettings) { _ in },
      .receive(.loadedTimerSettings(mockSettings)) { $0.timerSettings = mockSettings }
    )
  }
}
