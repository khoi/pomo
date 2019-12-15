//
//  AppState.swift
//  pomo
//
//  Created by khoi on 10/16/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Combine
import Foundation

struct AppState {
  var defaultDuration: TimeInterval = TimeInterval(5)
  var breakDureation: TimeInterval = TimeInterval(3)
  var longBreakDuration: TimeInterval = TimeInterval(10)

  var started: Date?
  var activityLogs = [String]()

  var currentRound = 1
  var totalRound = 8 // including breaks
}

extension AppState {
  var currentWorkingRound: Int {
    (currentRound + 1) / 2
  }

  var workingRounds: Int {
    totalRound / 2
  }

  var isBreak: Bool {
    currentRound % 2 == 0
  }
}

enum AppMutation {
  case goToNextRound
  case startTimer
  case stopTimer
  case addActivityLogs(String)
  case resetRound
}

enum AppAction: Action {
  case startTimer
  case stopTimer
  case advanceToNextRound
  case reset

  func mapToMutation() -> AnyPublisher<AppMutation, Never> {
    switch self {
    case .startTimer:
      return [
        .addActivityLogs("startTimer"),
        .startTimer,
      ]
      .publisher
      .eraseToAnyPublisher()
    case .stopTimer:
      return [
        .addActivityLogs("stopTimer"),
        .stopTimer,
      ]
      .publisher
      .eraseToAnyPublisher()
    case .advanceToNextRound:
      return [
        .addActivityLogs("skip"),
        .stopTimer,
        .goToNextRound,
      ]
      .publisher
      .eraseToAnyPublisher()
    case .reset:
      return [
        .addActivityLogs("reset"),
        .stopTimer,
        .resetRound,
      ]
      .publisher
      .eraseToAnyPublisher()
    }
  }
}

func appMutator(state: inout AppState, mutation: AppMutation) {
  switch mutation {
  case .startTimer:
    state.started = Date()
  case .stopTimer:
    state.started = nil
  case let .addActivityLogs(log):
    state.activityLogs.append(log)
  case .goToNextRound:
    state.currentRound = state.currentRound == state.totalRound ? 1 : state.currentRound + 1
  case .resetRound:
    state.currentRound = 1
  }
}
