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
  var started: Date?
  var defaultDuration: TimeInterval = TimeInterval(1 * 25 * 60)
  var activityLogs = [String]()
}

enum AppMutation {
  case startTimer
  case stopTimer
  case addActivityLogs(String)
}

enum AppAction: Action {
  case startTimer
  case stopTimer

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
  }
}
