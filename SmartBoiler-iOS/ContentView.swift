//
//  ContentView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/21/25.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("AppID") var appId = ""

    let numbers: [Int] = []
    
    var body: some View {
        NavigationStack {
            if numbers.isEmpty {
                OnboardingHero()
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
