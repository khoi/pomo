//
//  AppState.swift
//  pomo
//
//  Created by khoi on 10/16/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

struct AppState {
  var started: Date?
  var defaultDuration: TimeInterval = TimeInterval(1 * 30)
  var activityLogs = [String]()
}

enum AppMutation {
  case startTimer
  case stopTimer
  case addActivityLogs(String)
}

enum AppAction {
  case startTimer
  case stopTimer
}

func appMutator(state: inout AppState, mutation: AppMutation) {
  switch mutation {
  case .startTimer:
    state.started = Date()
  case .stopTimer:
    state.started = nil
  case .addActivityLogs(let log):
    state.activityLogs.append(log)
  }
}

func startTimer() -> Effect<String> {
  return Effect { callback in
    callback("Yolo")
  }
}

func appDispatcher(action: AppAction) -> [Effect<AppMutation>]  {
  switch action {
  case .startTimer:
    return [Effect { callback in
      callback(.startTimer)
      callback(.addActivityLogs("Start timer"))
    }.receive(on: .main)]
  case .stopTimer:
    return [Effect { callback in
      callback(.stopTimer)
      callback(.addActivityLogs("Stop timer"))
    }.receive(on: .main)]
  }
}
