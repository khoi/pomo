//
//  AppState.swift
//  pomo
//
//  Created by khoi on 10/16/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation
import CoreGraphics
import Combine

class AppState: ObservableObject {
    @Published var progress: CGFloat = 0.75
}
