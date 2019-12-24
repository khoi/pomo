//
//  SettingsView.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    VStack {
      ZStack {
        HStack {
          Spacer()
          Text("SETTINGS").font(.headline)
          Spacer()
        }
        HStack {
          Spacer()
          Button(action: {
            self.presentationMode.wrappedValue.dismiss()
          }) {
            Text("Done")
              .fontWeight(.semibold)
              .foregroundColor(Color("zima"))
          }
        }
      }.padding(8)
      Spacer()
      Group {
        Text("Version Number")
        Text("\(UIApplication.appVersion) (\(UIApplication.appBuildNumber))")
      }
      .font(.footnote)
    }
    .background(Color("background"))
    .foregroundColor(Color("text"))
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SettingsView().environment(\.colorScheme, .light)
      SettingsView().environment(\.colorScheme, .dark)
    }
    .previewLayout(PreviewLayout.fixed(width: 500, height: 800))
  }
}
