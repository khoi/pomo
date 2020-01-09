//
//  SettingsView.swift
//  pomo
//
//  Created by Danh Dang on 1/4/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject var store: Store<TimerSettings, SettingsAction>
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  fileprivate static let intervals: [Int] = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]

  @State private var workIntervalIndex: Int = 0
  @State private var shortBreakIndex: Int = 0
  @State private var longBreakIndex: Int = 0
  @State private var isSoundEnabled = false

  var body: some View {
    NavigationView {
      Form {
        Section {
          Picker("Work interval", selection: $workIntervalIndex) {
            ForEach(0 ..< Self.intervals.count, id: \.self) {
              Text("\(Self.intervals[$0]) mins")
            }
          }

          Picker("Shot break", selection: $shortBreakIndex) {
            ForEach(0 ..< Self.intervals.count, id: \.self) {
              Text("\(Self.intervals[$0]) mins")
            }
          }

          Picker("Long break", selection: $longBreakIndex) {
            ForEach(0 ..< Self.intervals.count, id: \.self) {
              Text("\(Self.intervals[$0]) mins")
            }
          }
        }.padding()

        Section {
          Toggle(isOn: $isSoundEnabled) {
            Text("Sounds on/off")
          }

          NavigationLink(destination: AboutView()) {
            Text("About")
          }
        }.padding()
      }
      .navigationBarTitle(Text("Settings"), displayMode: .inline)
      .navigationBarItems(trailing:
        Button("Save") {
          self.store.send(.saveTimerSettings(
            interval(at: self.workIntervalIndex),
            interval(at: self.shortBreakIndex),
            interval(at: self.longBreakIndex)
          )
          )
          self.presentationMode.wrappedValue.dismiss()
      })
    }
    .onAppear {
      self.workIntervalIndex = intervalIndex(of: self.store.value.workDuration)
      self.shortBreakIndex = intervalIndex(of: self.store.value.breakDuration)
      self.longBreakIndex = intervalIndex(of: self.store.value.longBreakDuration)
    }
  }
}

private func intervalIndex(of duration: TimeInterval) -> Int {
  let intervalInMinutes = Int(duration / 60)
  return SettingsView.intervals.firstIndex(of: intervalInMinutes) ?? 0
}

private func interval(at index: Int) -> TimeInterval {
  guard index < SettingsView.intervals.count else { return 0 }
  return Double(SettingsView.intervals[index] * 60)
}

#if DEBUG
  struct SettingsView_Previews: PreviewProvider {
    static let store = Store<TimerSettings, SettingsAction>(initialValue: TimerSettings(), reducer: settingsReducer)
    static var previews: some View {
      Group {
        NavigationView {
          SettingsView(store: store).environment(\.colorScheme, .light)
        }

        SettingsView(store: store).environment(\.colorScheme, .dark)
      }
      .previewLayout(PreviewLayout.fixed(width: 500, height: 600))
    }
  }
#endif
