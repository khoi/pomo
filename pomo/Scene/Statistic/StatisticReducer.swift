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

extension StatisticEnvironment {
  static let live = StatisticEnvironment { () -> Effect<Statistic> in
    .sync { () -> Statistic in
      return (today: getTodayPomoCount(),
              thisWeek: getThisWeekPomoCount(),
              thisMonth: getThisMonthPomoCount(),
              thisYear: getThisYearPomoCount())
    }
  }
}

private func getTodayPomoCount() -> Int {
  let calendar = Calendar.current
  let startDate = calendar.startOfDay(for: CurrentTimerEnvironment.date())
  let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
  return getPomodorosCount(from: startDate, to: endDate)
}

private func getThisWeekPomoCount() -> Int {
  let calendar = Calendar.current
  let today = CurrentTimerEnvironment.date()
  let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
  guard let lastSunday = calendar.date(from: components),
    let monday = calendar.date(byAdding: DateComponents(day: 1), to: lastSunday) else {
      return 0
  }
  return getPomodorosCount(from: monday, to: today)
}

private func getThisMonthPomoCount() -> Int {
  let calendar = Calendar.current
  let today = CurrentTimerEnvironment.date()
  let components = calendar.dateComponents([.year, .month], from: today)
  guard let startOfMonth = calendar.date(from: components) else {
    return 0
  }
  return getPomodorosCount(from: startOfMonth, to: today)
}

private func getThisYearPomoCount() -> Int {
  let calendar = Calendar.current
  let today = CurrentTimerEnvironment.date()
  let components = calendar.dateComponents([.year], from: today)
  guard let startOfYear = calendar.date(from: components) else {
    return 0
  }
  return getPomodorosCount(from: startOfYear, to: today)
}

private func getPomodorosCount(from startDate: Date, to endDate: Date) -> Int {
  let fetchRequest: NSFetchRequest<Pomodoro> = Pomodoro.fetchRequest()
  fetchRequest.predicate = NSPredicate(format: "started >= %@ && started <= %@", startDate as NSDate, endDate as NSDate)
  return (try? CoreDataStack.shared.persistentContainer.viewContext.count(for: fetchRequest)) ?? 0
}

#if DEBUG
  extension StatisticEnvironment {
    static let mock = StatisticEnvironment { () -> Effect<Statistic> in
      .sync { () -> Statistic in
        (today: 1, thisWeek: 2, thisMonth: 3, thisYear: 4)
      }
    }
  }
#endif

var CurrentStatisticEnvironment = StatisticEnvironment.live
