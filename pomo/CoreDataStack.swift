//
//  CoreDataStack.swift
//  Pomo
//
//  Created by khoi on 11/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Combine
import CoreData
import Foundation
import os.log

class CoreDataStack {
  static let shared = CoreDataStack()

  private init() {}

  private var cancellables = Set<AnyCancellable>()

  // Queue for processing change from Cloudkit
  private lazy var backgroundProcessQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()

  lazy var persistentContainer: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "pomo")

    // Enable history tracking and remote notifications
    guard let description = container.persistentStoreDescriptions.first else {
      fatalError("###\(#function): Failed to retrieve a persistent store description.")
    }
    description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey) // listen for changes from CloudKit

    container.loadPersistentStores(completionHandler: { _, error in
      guard let error = error as NSError? else { return }
      fatalError("###\(#function): Failed to load persistent stores:\(error)")
    })

    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.transactionAuthor = "app"

    // Pin the viewContext to the current generation token and set it to keep itself up to date with local changes.
    container.viewContext.automaticallyMergesChangesFromParent = true

    do {
      try container.viewContext.setQueryGenerationFrom(.current)
    } catch {
      fatalError("###\(#function): Failed to pin viewContext to the current generation:\(error)")
    }

    // Observe Core Data remote change notifications.
    NotificationCenter
      .default
      .publisher(for: .NSPersistentStoreRemoteChange, object: nil)
      .sink(receiveValue: processRemoteChange)
      .store(in: &cancellables)

    return container
  }()

  func processRemoteChange(_: Notification) {
    backgroundProcessQueue.addOperation {
      let context = self.persistentContainer.newBackgroundContext()
      context.performAndWait {}
    }
    os_log("CoreDataStack: Merging changes from the other persistent store coordinator.")
  }
}
