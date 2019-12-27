//
//  StatisticReducer.swift
//  pomo
//
//  Created by khoi on 12/27/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Combine
import Foundation

let statisticReducer = Reducer<StatisticState, StatisticAction> { (state, action) -> Effect<StatisticAction> in
  switch action {
  case .loadStatistic:
    return CurrentStatisticEnvironment
      .loadStatistic()
      .map(StatisticAction.loadedStatistic)
      .eraseToEffect()
  case let .loadedStatistic(today, thisWeek, thisMonth, thisYear):
    state.sessionCountToday = today
    state.sessionCountThisWeek = thisWeek
    state.sessionCountThisMonth = thisMonth
    state.sessionCountThisYear = thisYear
    return .empty()
  }
}

typealias Statistic = (today: Int, thisWeek: Int, thisMonth: Int, thisYear: Int)

struct StatisticState {
  var sessionCountToday: Int = 0
  var sessionCountThisWeek: Int = 0
  var sessionCountThisMonth: Int = 0
  var sessionCountThisYear: Int = 0
}

enum StatisticAction {
  case loadStatistic
  case loadedStatistic(Statistic)
}

struct StatisticEnvironment {
  var loadStatistic: () -> Effect<Statistic>
}

#if DEBUG
  extension StatisticEnvironment {
    static let mock = StatisticEnvironment.init { () -> Effect<Statistic> in
      .sync { () -> Statistic in
        (today: 1, thisWeek: 2, thisMonth: 3, thisYear: 4)
      }
    }
  }
#endif

var CurrentStatisticEnvironment = StatisticEnvironment.mock
