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
}

enum AppMutation {
  case startTimer
  case stopTimer
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
  }
}

func appDispatcher(action: AppAction, commit: @escaping (AppMutation) -> Void) -> Effect?  {
  switch action {
  case .startTimer:
    return {
      commit(.startTimer)
    }
  case .stopTimer:
    return {
      commit(.stopTimer)
    }
  }
}
