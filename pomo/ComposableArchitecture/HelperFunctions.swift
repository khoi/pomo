//
//  HelperFunctions.swift
//  pomo
//
//  Created by khoi on 2/29/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import CasePaths
import Combine
import Foundation

public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
  .init { value, action in
    let effects = reducers.compactMap { $0.reduce(&value, action) }
    return Publishers.MergeMany(effects).eraseToEffect()
  }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: CasePath<GlobalAction, LocalAction>
) -> Reducer<GlobalValue, GlobalAction> {
  .init { globalValue, globalAction in
    guard let localAction = action.extract(from: globalAction) else {
      return Empty(completeImmediately: true).eraseToEffect()
    }

    let localEffects = reducer.reduce(&globalValue[keyPath: value], localAction)

    return localEffects
      .map(action.embed)
      .eraseToEffect()
  }
}

public func logging<Value, Action>(
  _ reducer: Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return Reducer { value, action in
    let effects = reducer.reduce(&value, action)
    let newValue = value
    let loggingEffect = Effect<Action>.fireAndForget {
      print("Action: \(action)")
      print("Value:")
      dump(newValue)
      print("---")
    }
    return loggingEffect.merge(with: effects).eraseToEffect()
  }
}
