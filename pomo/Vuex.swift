//
//  Redux.swift
//  pomo
//
//  Created by khoi on 10/31/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation
import Combine

typealias Mutator<State, Mutation> = (inout State, Mutation) -> Void
typealias Dispatcher<Action, Mutation> = (Action) -> [Effect<Mutation>]

public struct Effect<A> {
  public let run: (@escaping (A) -> Void) -> Void
  
  public init(run: @escaping (@escaping (A) -> Void) -> Void) {
    self.run = run
  }
  
  public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
    return Effect<B> { callback in self.run { a in callback(f(a)) } }
  }
  
  public func receive(on queue: DispatchQueue) -> Effect {
    return Effect { callback in
      self.run { a in
        queue.async {
          callback(a)
        }
      }
    }
  }
}

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
    let effects = dispatcher(action)
    effects.forEach { (effect) in
      effect.run(self.commit)
    }
  }
}

func logger<State, Mutation>(_ mutator: @escaping Mutator<State, Mutation>) -> Mutator<State, Mutation> {
  return { state, mutation in
    print("dispatching \(mutation)")
    mutator(&state, mutation)
  }
}
