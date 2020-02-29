//
//  Helper.swift
//  pomoTests
//
//  Created by khoi on 1/15/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import Combine
@testable import pomo
import XCTest

enum StepType {
  case send
  case receive
}

struct Step<Value, Action> {
  let type: StepType
  let action: Action
  let update: (inout Value) -> Void
  let file: StaticString
  let line: UInt

  init(
    _ type: StepType,
    _ action: Action,
    file: StaticString = #file,
    line: UInt = #line,
    _ update: @escaping (inout Value) -> Void
  ) {
    self.action = action
    self.update = update
    self.file = file
    self.line = line
    self.type = type
  }

  static func send(_ action: Action,
                   file: StaticString = #file,
                   line: UInt = #line,
                   _ update: @escaping (inout Value) -> Void) -> Step<Value, Action> {
    .init(.send, action, file: file, line: line, update)
  }

  static func receive(_ action: Action,
                      file: StaticString = #file,
                      line: UInt = #line,
                      _ update: @escaping (inout Value) -> Void) -> Step<Value, Action> {
    .init(.receive, action, file: file, line: line, update)
  }
}

func assert<Value: Equatable, Action: Equatable>(
  initialValue: Value,
  reducer: Reducer<Value, Action>,
  steps: Step<Value, Action>...
) {
  var state = initialValue
  var actions: [Action] = []

  steps.forEach { step in
    var expected = state

    if step.type == .receive {
      guard !actions.isEmpty else {
        XCTFail("Action sent before handling \(actions.count) pending action(s)", file: step.file, line: step.line)
        return
      }
      XCTAssertEqual(step.action, actions.removeFirst(), file: step.file, line: step.line)
    }

    let effect = reducer(&state, step.action)
    let receivedCompletion = XCTestExpectation(description: "receivedCompletion")

    _ = effect.sink(
      receiveCompletion: { _ in receivedCompletion.fulfill() },
      receiveValue: {
        actions.append($0)
      }
    )

    if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
      XCTFail("Timed out waiting for effect to complete")
    }

    step.update(&expected)
    XCTAssertEqual(state, expected, file: step.file, line: step.line)
  }
}
