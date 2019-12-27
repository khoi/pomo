//
//  UserDefaults+PropertyWrapper.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
  private let key: String
  private let defaultValue: T
  private let userDefaults: UserDefaults

  init(_ key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
    self.key = key
    self.defaultValue = defaultValue
    self.userDefaults = userDefaults
  }

  var wrappedValue: T {
    get {
      return userDefaults.object(forKey: key) as? T ?? defaultValue
    }
    set {
      if let value = newValue as? OptionalProtocol, value.isNil() {
        userDefaults.removeObject(forKey: key)
      } else {
        userDefaults.set(newValue, forKey: key)
      }
    }
  }
}

private protocol OptionalProtocol {
  func isNil() -> Bool
}

extension Optional: OptionalProtocol {
  func isNil() -> Bool {
    return self == nil
  }
}
