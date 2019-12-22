//
//  Utils.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

func compose<A, B, C>(
  _ f: @escaping (B) -> C,
  _ g: @escaping (A) -> B
)
  -> (A) -> C {
  return { (a: A) -> C in
    f(g(a))
  }
}
