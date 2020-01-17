//
//  Settings.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import Foundation

struct AppSettings {
    @UserDefault("work_duration", defaultValue: 25 * 60)
    static var workDuration: TimeInterval

    @UserDefault("break_duration", defaultValue: 5 * 60)
    static var breakDuration: TimeInterval

    @UserDefault("long_break_duration", defaultValue: 20 * 60)
    static var longBreakDuration: TimeInterval

    @UserDefault("session_count", defaultValue: 4)
    static var sessionCount: Int

    @UserDefault<Date?>("session_started", defaultValue: nil)
    static var sessionStarted: Date?

    @UserDefault("current_session", defaultValue: 1)
    static var currentSession: Int

    @UserDefault("sound_enabled", defaultValue: false)
    static var isSoundEnabled: Bool
}
