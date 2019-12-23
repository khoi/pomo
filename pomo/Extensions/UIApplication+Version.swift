//
//  UIApplication+Version.swift
//  pomo
//
//  Created by khoi on 12/23/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import UIKit

extension UIApplication {
  static var appVersion: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
  }

  static var appBuildNumber: String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
  }
}
