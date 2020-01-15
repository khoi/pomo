//
//  TimerReducerTests.swift
//  pomoTests
//
//  Created by khoi on 1/14/20.
//  Copyright © 2020 khoi. All rights reserved.
//

@testable import pomo
import XCTest

class TimerReducerTests: XCTestCase {
  func testResetTimer() {
    var state = TimerState(currentSession: 3, timerSettings: TimerSettings(), started: Date())

    let effect = timerReducer.reduce(&state, .reset)

    XCTAssertEqual(state, TimerState(currentSession: 1, timerSettings: TimerSettings(), started: nil))
  }
}
