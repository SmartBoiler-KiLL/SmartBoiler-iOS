//
//  SetupWiFi.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/24/25.
//

import SwiftUI

struct SetupKiLLConnectionView: View {

    @Environment(LocalNetworkSetupManager.self) var localNetworkManager

    let maximumAttempts = 10

    @State var hasGoneToSettings = false
    @State var isConnected = false

    @State var searchingForKiLL = false
    @State var attemptNumber = 1
    @State var showErrorAlert = false

    var body: some View {
        VStack {
            Text("KiLL Network")
                .font(.title.bold())
                .foregroundStyle(.black)

            Text("Connect to a KiLL network to start setting it up.")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)

            Button(hasGoneToSettings ? "I'm connected to KiLL" : "Open Settings") {
                if !hasGoneToSettings {
                    if let url = URL(string: "App-prefs:WIFI") {
                        UIApplication.shared.open(url)
                        hasGoneToSettings = true
                    }
                } else {
                    isConnected = true
                    getmDNS()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.darkKiLLGray)
            .foregroundStyle(.white)
            .disabled(isConnected)

            if searchingForKiLL {
                ProgressView("Establishing connection... (Attempt \(attemptNumber)/\(maximumAttempts))")
                    .dynamicTypeSize(.small)
                    .tint(.darkKiLLGray)
            }
        }
        .foregroundStyle(.gray)
        .padding()
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .alert("KiLL Not Found", isPresented: $showErrorAlert) {
            Button("Retry", role: .cancel, action: retryConnection)
            Button("Cancel", role: .destructive) {
                showErrorAlert = false
                searchingForKiLL = false
            }
        } message: {
            Text("Please make sure that KiLL is powered on and you're connected to its network.")
        }

    }

    func getmDNS() {
        searchingForKiLL = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            localNetworkManager.getLocalmDNS()
            if (localNetworkManager.isUsingmDNS) {
                timer.invalidate()
                withAnimation {
                    searchingForKiLL = false
                }
            } else {
                print("Failed attempt \(attemptNumber)")
                if attemptNumber >= maximumAttempts {
                    showErrorAlert = true
                    timer.invalidate()
                } else {
                    attemptNumber += 1
                }
            }
        }
    }

    func retryConnection() {
        searchingForKiLL = true
        showErrorAlert = false
        attemptNumber = 1
        getmDNS()
    }
}

#Preview {
    struct SetupKiLLConnectionView_Previews: View {
        @State var localNetworkManager = LocalNetworkSetupManager()
        var body: some View {
            SetupKiLLConnectionView()
                .environment(localNetworkManager)
        }
    }

    return SetupKiLLConnectionView_Previews()
}
