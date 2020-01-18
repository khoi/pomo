//
//  SettingsContainer.swift
//  pomo
//
//  Created by Danh Dang on 1/4/20.
//  Copyright © 2020 khoi. All rights reserved.
//

import SwiftUI

struct SettingsContainer: View {
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
        }.padding()

        Section {
          HStack {
            Text("Version")
            Spacer()
            Text("\(UIApplication.appVersion) (\(UIApplication.appBuildNumber))")
          }

        }.padding()
      }
      .navigationBarTitle(Text("Settings"), displayMode: .inline)
      .navigationBarItems(trailing:
        Button("Done") {
          self.store.send(.saveTimerSettings(
            TimerSettings(workDuration: interval(at: self.workIntervalIndex),
                          breakDuration: interval(at: self.shortBreakIndex),
                          longBreakDuration: interval(at: self.longBreakIndex),
                          soundEnabled: self.isSoundEnabled)
          ))
          self.presentationMode.wrappedValue.dismiss()
      }.foregroundColor(Color("zima")))
    }.foregroundColor(Color("text"))
      .onAppear {
        self.workIntervalIndex = intervalIndex(of: self.store.value.workDuration)
        self.shortBreakIndex = intervalIndex(of: self.store.value.breakDuration)
        self.longBreakIndex = intervalIndex(of: self.store.value.longBreakDuration)
        self.isSoundEnabled = self.store.value.soundEnabled
      }
  }
}

private func intervalIndex(of duration: TimeInterval) -> Int {
  let intervalInMinutes = Int(duration / 60)
  return SettingsContainer.intervals.firstIndex(of: intervalInMinutes) ?? 0
}

private func interval(at index: Int) -> TimeInterval {
  guard index < SettingsContainer.intervals.count else { return 0 }
  return Double(SettingsContainer.intervals[index])
}

#if DEBUG
  struct SettingsContainer_Previews: PreviewProvider {
    static let store = Store<TimerSettings, SettingsAction>(initialValue: TimerSettings(), reducer: settingsReducer)
    static var previews: some View {
      Group {
        NavigationView {
          SettingsContainer(store: store).environment(\.colorScheme, .light)
        }

        SettingsContainer(store: store).environment(\.colorScheme, .dark)
      }
      .previewLayout(PreviewLayout.fixed(width: 500, height: 600))
    }
  }
#endif
