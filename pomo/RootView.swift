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

  var body: some View {
    TimerContainer(store:
      store.view(value: { $0.timer },
                 action: { .timer($0) }),
                   openStatistic: { self.showingStatisticModal.toggle() })
      .sheet(isPresented: $showingStatisticModal) {
        StatisticView(store: self.store.view(value: { $0.statistic }, action: { .statistic($0) }))
      }
  }
}
