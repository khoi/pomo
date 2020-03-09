//
//  Functions.swift
//  pomo
//
//  Created by khoi on 3/9/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import CoreData
import Foundation

private var calendar: Calendar {
  var calendar = Calendar.current
  calendar.firstWeekday = 2
  return calendar
}

func getTodayPomoCount(date: Date) -> Int {
  getPomodorosCount(from: calendar.startOfDay(for: date), to: date)
}

func getThisWeekPomoCount(date: Date) -> Int {
  let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
  guard let monday = calendar.date(from: components) else {
    return 0
  }
  return getPomodorosCount(from: monday, to: date)
}

func getThisMonthPomoCount(date: Date) -> Int {
  let components = calendar.dateComponents([.year, .month], from: date)
  guard let startOfMonth = calendar.date(from: components) else {
    return 0
  }
  return getPomodorosCount(from: startOfMonth, to: date)
}

func getThisYearPomoCount(date: Date) -> Int {
  let components = calendar.dateComponents([.year], from: date)
  guard let startOfYear = calendar.date(from: components) else {
    return 0
  }
  return getPomodorosCount(from: startOfYear, to: date)
}

func getPomodorosCount(from startDate: Date, to endDate: Date) -> Int {
  let fetchRequest: NSFetchRequest<Pomodoro> = Pomodoro.fetchRequest()
  fetchRequest.predicate = NSPredicate(format: "text == %@ && started >= %@ && started <= %@", "Focus", startDate as NSDate, endDate as NSDate)
  return (try? CoreDataStack.shared.persistentContainer.viewContext.count(for: fetchRequest)) ?? 0
}
