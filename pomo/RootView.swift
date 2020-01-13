//
//  RootView.swift
//  pomo
//
//  Created by khoi on 12/27/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct RootView: View {
  @ObservedObject var store: Store<AppState, AppAction>
  
  @State private var showingStatisticModal = false
  @State private var showingSettingsModal = false
  
  var body: some View {
    TimerContainer(store:
      store.view(value: { $0.timer },
                 action: { .timer($0) }),
                   openStatistic: { self.showingStatisticModal.toggle() },
                   openSettings: { self.showingSettingsModal.toggle() })
      .sheet(isPresented: $showingStatisticModal) {
        StatisticContainer(store: self.store.view(value: { $0.statistic }, action: { .statistic($0) }))
    }
      // FIXME: A temporary hack to attach multiple sheets to a view
      .background(EmptyView().sheet(isPresented: $showingSettingsModal, onDismiss: {
        self.store.send(.timer(.loadTimerSettings))
      }) {
        SettingsContainer(store: self.store.view(value: { $0.timer.timerSettings }, action: { .settings($0) }))
      })
  }
}
