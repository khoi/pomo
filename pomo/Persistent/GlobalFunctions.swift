//
//  GlobalFunctions.swift
//  pomo
//
//  Created by khoi on 1/18/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import CoreData

func getPomodorosCount(from startDate: Date, to endDate: Date, text: String? = nil) -> Int {
  let fetchRequest: NSFetchRequest<Pomodoro> = Pomodoro.fetchRequest()
  if let text = text {
    fetchRequest.predicate = NSPredicate(format: "text == %@ && started >= %@ && started <= %@", text, startDate as NSDate, endDate as NSDate)
  } else {
    fetchRequest.predicate = NSPredicate(format: "started >= %@ && started <= %@", startDate as NSDate, endDate as NSDate)
  }
  return (try? CoreDataStack.shared.persistentContainer.viewContext.count(for: fetchRequest)) ?? 0
}

func getPomodoros(from startDate: Date, to endDate: Date, text: String? = nil) -> [Pomodoro] {
  let fetchRequest: NSFetchRequest<Pomodoro> = Pomodoro.fetchRequest()
  if let text = text {
    fetchRequest.predicate = NSPredicate(format: "text == %@ && started >= %@ && started <= %@", text, startDate as NSDate, endDate as NSDate)
  } else {
    fetchRequest.predicate = NSPredicate(format: "started >= %@ && started <= %@", startDate as NSDate, endDate as NSDate)
  }
  return (try? CoreDataStack.shared.persistentContainer.viewContext.fetch(fetchRequest)) ?? []
}

func getFocusPomodoros(from startDate: Date, to endDate: Date) -> [Pomodoro] {
  return getPomodoros(from: startDate, to: endDate, text: "Focus")
}
