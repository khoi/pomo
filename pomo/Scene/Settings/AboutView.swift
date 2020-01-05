//
//  SettingsView.swift
//  pomo
//
//  Created by khoi on 12/22/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct AboutView: View {
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    VStack {
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

#if DEBUG
  struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        AboutView().environment(\.colorScheme, .light)
        AboutView().environment(\.colorScheme, .dark)
      }
      .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
    }
  }
#endif
