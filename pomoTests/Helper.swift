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
                   _ update: @escaping (inout Value) -> Void) -> Step<Value, Action> {
    .init(.send, action, update)
  }

  static func receive(_ action: Action,
                      _ update: @escaping (inout Value) -> Void) -> Step<Value, Action> {
    .init(.receive, action, update)
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

    switch step.type {
    case .send:
      let effect = reducer.reduce(&state, step.action)
      let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
      _ = effect.collect().sink(
        receiveCompletion: { _ in receivedCompletion.fulfill() },
        receiveValue: {
          actions.append(contentsOf: $0)
        }
      )

      if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
        XCTFail("Timed out waiting for effect to complete")
      }
    case .receive:
      guard !actions.isEmpty else {
        XCTFail("Action sent before handling \(actions.count) pending action(s)", file: step.file, line: step.line)
        break
      }
      XCTAssertEqual(step.action, actions.removeFirst(), file: step.file, line: step.line)

      let effect = reducer.reduce(&state, step.action)
      let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
      _ = effect.collect().sink(
        receiveCompletion: { _ in receivedCompletion.fulfill() },
        receiveValue: {
          actions.append(contentsOf: $0)
        }
      )

      if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
        XCTFail("Timed out waiting for effect to complete")
      }
    }

    step.update(&expected)
    XCTAssertEqual(state, expected, file: step.file, line: step.line)
  }
}
