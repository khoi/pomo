//
//  HapticProvider.swift
//  pomo
//
//  Created by Danh Dang on 1/19/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import AVFoundation
import ComposableArchitecture
import UIKit

protocol HapticProvider {
  func impactOccured() -> Effect<Never>
  func playSound() -> Effect<Never>
}

struct iOSHapticProvider: HapticProvider {
  private let impactGenerator: UIImpactFeedbackGenerator
  private let audioPlayer: AVAudioPlayer

  init() {
    impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let completedTimerSoundURL = Bundle.main.url(forResource: "timer_completed", withExtension: "wav")!
    audioPlayer = try! AVAudioPlayer(contentsOf: completedTimerSoundURL)
    audioPlayer.prepareToPlay()
  }

  func impactOccured() -> Effect<Never> {
    .fireAndForget {
      self.impactGenerator.impactOccurred(intensity: 1)
    }
  }

  func playSound() -> Effect<Never> {
    .fireAndForget {
      self.audioPlayer.play()
      AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
  }
}

#if DEBUG

  struct ConsoleHapticProvider: HapticProvider {
    func impactOccured() -> Effect<Never> {
      .fireAndForget {
        print("impact occured")
      }
    }

    func playSound() -> Effect<Never> {
      .fireAndForget {
        print("play sound")
      }
    }
  }

#endif
