//
//  StatisticContainer.swift
//  pomo
//
//  Created by khoi on 12/27/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct StatisticContainer: View {
  @ObservedObject var store: Store<StatisticState, StatisticAction>

  var body: some View {
    VStack(spacing: 32) {
      VStack {
        VStack {
          Text("Sessions Today")
          Text("\(store.value.focusSessionToday)").font(.largeTitle)
        }
      }
      VStack {
        HStack(spacing: 16) {
          VStack {
            Text("focus minutes")
            Text("\(store.value.totalFocusTime)").font(.title)
          }
        }
      }
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    .background(Color("background"))
    .onAppear {
      self.store.send(.loadStatisticToday)
    }
  }
}

#if DEBUG
  struct StatisticView_Previews: PreviewProvider {
    static let store = Store<StatisticState, StatisticAction>(initialValue: StatisticState(), reducer: statisticReducer)

    static var previews: some View {
      Group {
        StatisticContainer(store: store).environment(\.colorScheme, .light)
        StatisticContainer(store: store).environment(\.colorScheme, .dark)
      }
      .previewLayout(PreviewLayout.fixed(width: 400, height: 400))
    }
  }
#endif
