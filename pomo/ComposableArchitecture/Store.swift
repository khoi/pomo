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
