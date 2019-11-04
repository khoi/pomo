//
//  Redux.swift
//  pomo
//
//  Created by khoi on 10/31/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

typealias Mutator<State, Mutation> = (inout State, Mutation) -> Void
typealias Dispatcher<Action, Mutation> = (Action, @escaping (Mutation) -> Void) -> Effect?
typealias Effect = () -> Void

final class Store<State, Mutation, Action>: ObservableObject {
  @Published public private(set) var state: State
  
  private let mutator: Mutator<State, Mutation>
  private let dispatcher: Dispatcher<Action, Mutation>
  
  init(state: State, mutator: @escaping Mutator<State, Mutation>, dispatcher: @escaping Dispatcher<Action, Mutation>) {
    self.state = state
    self.mutator = mutator
    self.dispatcher = dispatcher
  }
  
  func commit(_ mutation: Mutation) {
    mutator(&state, mutation)
  }
  
  func dispatch(_ action: Action) {
    if let effect = dispatcher(action, { [weak self] mutation in
      self?.commit(mutation)
    }) {
      effect()
    }
  }
}
