//
//  Home.swift
//  pomo
//
//  Created by khoi on 10/16/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct Home: View {
    @State var progress: CGFloat = 0.75
    @State var isShowingSettings = false
    
    var body: some View {
        VStack {
            Button(action: {
                self.isShowingSettings = true
            }) {
                Image(systemName: "gear").imageScale(.large)
            }
            ActivityRing(progress: $progress)
        }
        .sheet(isPresented: $isShowingSettings, onDismiss: {
            self.isShowingSettings = false
        }) {
            Text("Settings screen")
        }
    
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
