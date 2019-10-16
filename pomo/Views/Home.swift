//
//  Home.swift
//  pomo
//
//  Created by khoi on 10/16/19.
//  Copyright © 2019 khoi. All rights reserved.
//

import SwiftUI

struct Home: View {
    @ObservedObject var state: AppState
    @State var isShowingSettings = false
    
    var body: some View {
        VStack {
                Button(action: {
                    self.isShowingSettings = true
                }) {
                    Image(systemName: "gear").imageScale(.large)
                }
                
                Button(action: {
                    self.state.progress = CGFloat.random(in: 0...1)
                }) {
                    Text("Random Progress")
                }
               
                
            
            ActivityRing(progress: self.$state.progress)
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
        Home(state: AppState())
    }
}
