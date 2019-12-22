//
//  TimerEnvironment.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

public struct TimerEnvironment {}

extension TimerEnvironment {
  static let live = TimerEnvironment()
}

var CurrentTimerEnvironment = TimerEnvironment.live
