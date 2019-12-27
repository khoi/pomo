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

  var body: some View {
    TimerContainer(store: store.view(value: { $0.timer }, action: { AppAction.timer($0) }))
  }
}
