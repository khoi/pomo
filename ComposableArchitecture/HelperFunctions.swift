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

public func combine<Value, Action, Environment>(
  _ reducers: Reducer<Value, Action, Environment>...
) -> Reducer<Value, Action, Environment> {
  { value, action, environment in
    let effects = reducers.compactMap { $0(&value, action, environment) }
    return Publishers.MergeMany(effects).eraseToEffect()
  }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction, LocalEnvironment, GlobalEnvironment>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction, LocalEnvironment>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: CasePath<GlobalAction, LocalAction>,
  environment: @escaping (GlobalEnvironment) -> LocalEnvironment
) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
  return { globalValue, globalAction, globalEnvironment in
    guard let localAction = action.extract(from: globalAction) else {
      return Empty(completeImmediately: true).eraseToEffect()
    }

    let localEffects = reducer(&globalValue[keyPath: value], localAction, environment(globalEnvironment))

    return localEffects
      .map(action.embed)
      .eraseToEffect()
  }
}

public func logging<Value, Action, Environment>(
  _ reducer: @escaping Reducer<Value, Action, Environment>
) -> Reducer<Value, Action, Environment> {
  { value, action, environment in
    let effects = reducer(&value, action, environment)
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
