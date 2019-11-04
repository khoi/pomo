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

enum AppAction {
  case startTimer
  case stopTimer
}

func appReducer(state: inout AppState, action: AppAction) {
  switch action {
  case .startTimer:
    state.started = Date()
  case .stopTimer:
    state.started = nil
  }
}
