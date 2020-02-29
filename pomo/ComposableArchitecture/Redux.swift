import CasePaths
import Combine
import SwiftUI

public struct Reducer<Value, Action> {
  public let reduce: (inout Value, Action) -> Effect<Action>

  init(reduce: @escaping (inout Value, Action) -> Effect<Action>) {
    self.reduce = reduce
  }
}

public final class Store<Value, Action>: ObservableObject {
  private let reducer: Reducer<Value, Action>
  @Published public private(set) var value: Value
  private var viewCancellable: Cancellable?
  private var effectCancellables: Set<AnyCancellable> = []

  public init(initialValue: Value, reducer: Reducer<Value, Action>) {
    self.reducer = reducer
    value = initialValue
  }

  public func send(_ action: Action) {
    reducer.reduce(&value, action).sink(receiveValue: send).store(in: &effectCancellables)
  }

  public func view<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(value),
      reducer: Reducer { localValue, localAction in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return Empty(completeImmediately: true).eraseToEffect()
      }
    )
    localStore.viewCancellable = $value.sink { [weak localStore] newValue in
      localStore?.value = toLocalValue(newValue)
    }
    return localStore
  }
}

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
