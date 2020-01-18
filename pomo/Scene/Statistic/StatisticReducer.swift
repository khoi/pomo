//
//  StatisticReducer.swift
//  pomo
//
//  Created by khoi on 12/27/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Combine
import CoreData
import Foundation
import SwiftDate

let statisticReducer = Reducer<StatisticState, StatisticAction> { (state, action) -> Effect<StatisticAction> in
  switch action {
  case .loadStatisticToday:
    return CurrentStatisticEnvironment
      .loadStatisticToday()
      .map(StatisticAction.loadedStatisticToday)
      .eraseToEffect()
  case let .loadedStatisticToday(todayStatistic):
    state.focusSessionToday = todayStatistic.focusSessionToday
    state.totalFocusTime = todayStatistic.totalFocusTime
    return .empty()
  }
}

typealias StatisticToday = (focusSessionToday: Int, totalFocusTime: TimeInterval)

struct StatisticState {
  var focusSessionToday: Int = 0
  var totalFocusTime: TimeInterval = 0
}

enum StatisticAction {
  case loadStatisticToday
  case loadedStatisticToday(StatisticToday)
}

struct StatisticEnvironment {
  var loadStatisticToday: () -> Effect<StatisticToday>
  var date: () -> Date
}

extension StatisticEnvironment {
  static let live = StatisticEnvironment(loadStatisticToday: { () -> Effect<StatisticToday> in
    .sync { () -> StatisticToday in
      let startOfDay = DateInRegion().dateAt(.startOfDay).date
      let endOfDay = DateInRegion().dateAt(.endOfDay).date
      let todayPomos = getFocusPomodoros(from: startOfDay, to: endOfDay)

      return StatisticToday(
        focusSessionToday: todayPomos.count,
        totalFocusTime: todayPomos.reduce(0) { $0 + $1.duration }
      )
    }
  }, date: Date.init)
}

#if DEBUG
  extension StatisticEnvironment {
    static let mock = StatisticEnvironment(loadStatisticToday: { () -> Effect<StatisticToday> in
      .sync { () -> StatisticToday in
        StatisticToday(focusSessionToday: 14, totalFocusTime: 5000)
      }
    }, date: { Date(timeIntervalSince1970: 1_577_528_238) })
  }
#endif

var CurrentStatisticEnvironment = StatisticEnvironment.live
