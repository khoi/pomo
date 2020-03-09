//
//  StatisticReducer.swift
//  pomo
//
//  Created by khoi on 12/27/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Combine
import ComposableArchitecture
import CoreData
import Foundation

func statisticReducer(
  state: inout StatisticState,
  action: StatisticAction,
  environment: StatisticEnvironment
) -> Effect<StatisticAction> {
  switch action {
  case .loadStatistic:
    return environment
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

public typealias Statistic = (today: Int, thisWeek: Int, thisMonth: Int, thisYear: Int)

public struct StatisticState {
  var sessionCountToday: Int = 0
  var sessionCountThisWeek: Int = 0
  var sessionCountThisMonth: Int = 0
  var sessionCountThisYear: Int = 0
}

public enum StatisticAction {
  case loadStatistic
  case loadedStatistic(Statistic)
}

typealias StatisticEnvironment = (
  date: () -> Date,
  loadStatistic: () -> Effect<Statistic>
)
//
// extension StatisticEnvironment {
//  static let live = StatisticEnvironment(loadStatistic: { () -> Effect<Statistic> in
//    .sync { () -> Statistic in

//  }, date: Date.init)
// }
//

//
// #if DEBUG
//  extension StatisticEnvironment {
//    static let mock = StatisticEnvironment(loadStatistic: { () -> Effect<Statistic> in
//      .sync { () -> Statistic in
//        (today: 1, thisWeek: 2, thisMonth: 3, thisYear: 4)
//      }
//    }, date: { Date(timeIntervalSince1970: 1_577_528_238) })
//  }
// #endif
//
// var CurrentStatisticEnvironment = StatisticEnvironment.live
