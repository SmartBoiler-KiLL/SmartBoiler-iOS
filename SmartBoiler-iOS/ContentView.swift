//
//  ContentView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/21/25.
//

import SwiftUI

struct ContentView: View {
    
    let numbers: [Int] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.backgroundGradient.ignoresSafeArea()
                if numbers.isEmpty {
                    OnboardingHero()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
