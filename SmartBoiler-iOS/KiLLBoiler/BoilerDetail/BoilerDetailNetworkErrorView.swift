//
//  BoilerDetailNetworkErrorView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/28/25.
//

import SwiftUI

struct BoilerDetailNetworkErrorView: View {

    @Bindable var viewModel: BoilerViewModel
    @Binding var hasGoneToSettings: Bool
    @Binding var showingConnectedProgress: Bool

    var body: some View {
        VStack {
            Text("We can't seem to find your KiLL. If you're at home, you can connect to it using its network.")

            Button(hasGoneToSettings ? "I'm Connected" : "Open Settings") {
                if !hasGoneToSettings {
                    if let url = URL(string: "App-prefs:WIFI") {
                        UIApplication.shared.open(url)
                        hasGoneToSettings = true
                    }
                } else {
                    viewModel.setBoilerIP(KiLLBoiler.localNetworkIP)
                    showingConnectedProgress = true
                }
            }
            .buttonStyle(.borderedProminent)

            if showingConnectedProgress {
                ProgressView()
                    .tint(.white)
            }
        }
        .padding(.vertical, 5)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(LinearGradient(colors: [.secondaryKiLL, .secondary.opacity(0.3)], startPoint: .top, endPoint: .bottom))
        .clipShape(.rect(cornerRadius: 10))
        .onDisappear {
            showingConnectedProgress = false
            hasGoneToSettings = false
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
