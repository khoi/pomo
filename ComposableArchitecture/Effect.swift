//
//  Effect.swift
//  pomo
//
//  Created by khoi on 2/29/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import Combine
import Foundation

public struct Effect<Output>: Publisher {
  public typealias Failure = Never

  let publisher: AnyPublisher<Output, Failure>

  public func receive<S>(
    subscriber: S
  ) where S: Subscriber, Failure == S.Failure, Output == S.Input {
    publisher.receive(subscriber: subscriber)
  }
}

extension Publisher where Failure == Never {
  public func eraseToEffect() -> Effect<Output> {
    .init(publisher: eraseToAnyPublisher())
  }
}

extension Effect {
  public static func sync(work: @escaping () -> Output) -> Effect {
    Deferred {
      Just(work())
    }.eraseToEffect()
  }

  public static func fireAndForget(work: @escaping () -> Void) -> Effect {
    Deferred { () -> Empty<Output, Never> in
      work()
      return Empty(completeImmediately: true)
    }.eraseToEffect()
  }

  public static func empty() -> Effect {
    Empty(completeImmediately: true).eraseToEffect()
  }
}

extension Publisher where Output == Never, Failure == Never {
  public func fireAndForget<A>() -> Effect<A> {
    map { (_) -> A in }
      .eraseToEffect()
  }
}
