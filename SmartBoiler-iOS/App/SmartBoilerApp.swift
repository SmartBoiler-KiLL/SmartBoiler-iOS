//
//  SmartBoiler_iOSApp.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/21/25.
//

import SwiftUI

@main
struct KiLLApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [KiLLBoiler.self])
    }
}
