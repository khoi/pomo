//
//  Redux.swift
//  pomo
//
//  Created by khoi on 10/31/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

typealias Reducer<State, Action> = (inout State, Action) -> Void

final class Store<State, Action>: ObservableObject {
  @Published public private(set) var state: State

  private let reducer: Reducer<State, Action>

  init(state: State, reducer: @escaping Reducer<State, Action>) {
    self.state = state
    self.reducer = reducer
  }

  func send(_ action: Action) {
    reducer(&state, action)
  }
}
