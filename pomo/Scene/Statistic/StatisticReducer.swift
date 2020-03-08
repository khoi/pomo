////
////  StatisticReducer.swift
////  pomo
////
////  Created by khoi on 12/27/19.
////  Copyright © 2019 khoi. All rights reserved.
////
//
// import Combine
// import CoreData
// import Foundation
//
// public func statisticReducer(
//  state: inout StatisticState,
//  action: StatisticAction
// ) -> Effect<StatisticAction> {
//  switch action {
//  case .loadStatistic:
//    return CurrentStatisticEnvironment
//      .loadStatistic()
//      .map(StatisticAction.loadedStatistic)
//      .eraseToEffect()
//  case let .loadedStatistic(today, thisWeek, thisMonth, thisYear):
//    state.sessionCountToday = today
//    state.sessionCountThisWeek = thisWeek
//    state.sessionCountThisMonth = thisMonth
//    state.sessionCountThisYear = thisYear
//    return .empty()
//  }
// }
//
// public typealias Statistic = (today: Int, thisWeek: Int, thisMonth: Int, thisYear: Int)
//
// public struct StatisticState {
//  var sessionCountToday: Int = 0
//  var sessionCountThisWeek: Int = 0
//  var sessionCountThisMonth: Int = 0
//  var sessionCountThisYear: Int = 0
// }
//
// public enum StatisticAction {
//  case loadStatistic
//  case loadedStatistic(Statistic)
// }
//
// struct StatisticEnvironment {
//  var loadStatistic: () -> Effect<Statistic>
//  var date: () -> Date
// }
//
// extension StatisticEnvironment {
//  static let live = StatisticEnvironment(loadStatistic: { () -> Effect<Statistic> in
//    .sync { () -> Statistic in
//      (today: getTodayPomoCount(),
//       thisWeek: getThisWeekPomoCount(),
//       thisMonth: getThisMonthPomoCount(),
//       thisYear: getThisYearPomoCount())
//    }
//  }, date: Date.init)
// }
//
// private var calendar: Calendar {
//  var calendar = Calendar.current
//  calendar.firstWeekday = 2
//  return calendar
// }
//
// private func getTodayPomoCount() -> Int {
//  let currentTime = CurrentStatisticEnvironment.date()
//  let startOfToday = calendar.startOfDay(for: currentTime)
//  return getPomodorosCount(from: startOfToday, to: currentTime)
// }
//
// private func getThisWeekPomoCount() -> Int {
//  let today = CurrentStatisticEnvironment.date()
//  let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
//  guard let monday = calendar.date(from: components) else {
//    return 0
//  }
//  return getPomodorosCount(from: monday, to: today)
// }
//
// private func getThisMonthPomoCount() -> Int {
//  let today = CurrentStatisticEnvironment.date()
//  let components = calendar.dateComponents([.year, .month], from: today)
//  guard let startOfMonth = calendar.date(from: components) else {
//    return 0
//  }
//  return getPomodorosCount(from: startOfMonth, to: today)
// }
//
// private func getThisYearPomoCount() -> Int {
//  let calendar = Calendar.current
//  let today = CurrentStatisticEnvironment.date()
//  let components = calendar.dateComponents([.year], from: today)
//  guard let startOfYear = calendar.date(from: components) else {
//    return 0
//  }
//  return getPomodorosCount(from: startOfYear, to: today)
// }
//
// private func getPomodorosCount(from startDate: Date, to endDate: Date) -> Int {
//  let fetchRequest: NSFetchRequest<Pomodoro> = Pomodoro.fetchRequest()
//  fetchRequest.predicate = NSPredicate(format: "text == %@ && started >= %@ && started <= %@", "Focus", startDate as NSDate, endDate as NSDate)
//  return (try? CoreDataStack.shared.persistentContainer.viewContext.count(for: fetchRequest)) ?? 0
// }
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
