//
//  AppState.swift
//  pomo
//
//  Created by khoi on 10/16/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

struct AppState {
  var started: NSDate?
}

enum AppAction {
  case startTimer
}

func appReducer(state: inout AppState, action: AppAction) {
  switch action {
  case .startTimer:
    state.started = NSDate()
  }
}
