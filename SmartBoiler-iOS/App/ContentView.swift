//
//  ContentView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/21/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @AppStorage("AppID") var appId = ""

    @Query var boilers: [KiLLBoiler]

    var body: some View {
        NavigationStack {
            if boilers.isEmpty {
                OnboardingHero()
            } else {
                
            }
        }
        .onAppear {
            if appId.isEmpty {
                appId = UUID().uuidString.prefix(8).description
                print("Assigned appId: \(appId)")
            } else {
                print("Existing appId: \(appId)")
            }
        }
    }
}

#Preview {
    ContentView()
}
