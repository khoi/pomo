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
  { value, action in
    let effects = reducers.compactMap { $0(&value, action) }
    return Publishers.MergeMany(effects).eraseToEffect()
  }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: CasePath<GlobalAction, LocalAction>
) -> Reducer<GlobalValue, GlobalAction> {
  return { globalValue, globalAction in
    guard let localAction = action.extract(from: globalAction) else {
      return Empty(completeImmediately: true).eraseToEffect()
    }

    let localEffects = reducer(&globalValue[keyPath: value], localAction)

    return localEffects
      .map(action.embed)
      .eraseToEffect()
  }
}

public func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  { value, action in
    let effects = reducer(&value, action)
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
