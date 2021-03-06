//
//  SceneDelegate.swift
//  pomo
//
//  Created by khoi on 10/11/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  let store = Store(
    initialValue: AppState(),
    reducer: appReducer,
    environment: AppEnvironment(
      date: Date.init,
      timerSettingsRepository: .live,
      pomodoroRepository: .live,
      hapticHandler: TimerHapticHandler(provider: iOSHapticProvider()),
      loadStatistic: {
        .sync {
          let now = Date()
          return Statistic(today: getTodayPomoCount(date: now),
                           thisWeek: getThisWeekPomoCount(date: now),
                           thisMonth: getThisMonthPomoCount(date: now),
                           thisYear: getThisYearPomoCount(date: now))
        }
      }
    )
  )

  func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    // Create the SwiftUI view that provides the window contents.
    let context = CoreDataStack.shared.persistentContainer.viewContext

    let rootView = RootView(store: store)
      .environment(\.managedObjectContext, context)
    // Use a UIHostingController as window root view controller.
    if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(rootView: rootView)
      self.window = window
      window.makeKeyAndVisible()
    }
  }

  func sceneDidDisconnect(_: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    store.send(AppAction.timer(.saveCurrentSession))
    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
  }

  func sceneWillEnterForeground(_: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    store.send(AppAction.timer(.loadCurrentSession))
  }

  func sceneDidEnterBackground(_: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
}
