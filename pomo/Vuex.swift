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

protocol Action {
  associatedtype Mutation
  func mapToMutation() -> AnyPublisher<Mutation, Never>
}

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

final class Store<State, Mutation>: ObservableObject {
  @Published public private(set) var state: State
  
  private let mutator: Mutator<State, Mutation>
  private var cancellables: Set<AnyCancellable> = []
  
  init(state: State, mutator: @escaping Mutator<State, Mutation>) {
    self.state = state
    self.mutator = mutator
  }
  
  func commit(_ mutation: Mutation) {
    mutator(&state, mutation)
  }
  
  func dispatch<A: Action>(_ action: A) where A.Mutation == Mutation {
    action
      .mapToMutation()
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: commit)
      .store(in: &cancellables)
  }
}

func logger<State, Mutation>(_ mutator: @escaping Mutator<State, Mutation>) -> Mutator<State, Mutation> {
  return { state, mutation in
    print("commiting \(mutation)")
    mutator(&state, mutation)
  }
}
