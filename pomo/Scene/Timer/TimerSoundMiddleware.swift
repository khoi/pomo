//
//  TimerNotificationMiddleware.swift
//  pomo
//
//  Created by khoi on 12/23/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import AVFoundation
import Combine
import Foundation
import UIKit

func withSoundsAndVibrations(reducer: Reducer<TimerState, TimerAction>) -> Reducer<TimerState, TimerAction> {
  let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
  let completedTimerSoundURL = Bundle.main.url(forResource: "timer_completed", withExtension: "wav")!
  let audioPlayer = try! AVAudioPlayer(contentsOf: completedTimerSoundURL)
  audioPlayer.prepareToPlay()

  return Reducer { value, action in
    let soundEffect = Effect<TimerAction>.fireAndForget {
      switch action {
      case .startTimer, .stopTimer:
        impactGenerator.impactOccurred(intensity: 1)
      case .completeCurrentSession:
        audioPlayer.play()
        (0 ..< 3).forEach { _ in impactGenerator.impactOccurred(intensity: 1) }
      default:
        break
      }
    }
    return soundEffect.merge(with: reducer.run(&value, action)).eraseToEffect()
  }
}
