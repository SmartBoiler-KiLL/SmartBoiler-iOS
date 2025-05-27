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
    @State var showSetup = false

    var body: some View {
        NavigationStack {
            BoilersView(boilers: boilers)
        }
        .fullScreenCover(isPresented: $showSetup) {
            OnboardingHero()
        }
        .onAppear {
            showSetup = boilers.isEmpty
            
            if appId.isEmpty {
                appId = UUID().uuidString.prefix(8).description
                print("Assigned appId: \(appId)")
            } else {
                print("Existing appId: \(appId)")
            }
        }
        .onChange(of: boilers.count) {
            if boilers.count == 0 {
                showSetup = true
            }
        }
    }
}

#Preview {
    ContentView()
}
