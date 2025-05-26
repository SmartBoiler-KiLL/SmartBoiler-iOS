//
//  SetupKiLLWiFi.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/24/25.
//

import SwiftUI

struct SetupKiLLWiFiView: View {

    @Environment(LocalNetworkManager.self) var localNetworkManager

    let maximumAttempts = 10

    @AppStorage("AppID") var appId = ""

    @State var wifiSSID = ""
    @State var wifiPassword = ""

    @State var setupAttempt = 0
    @State var sendingCredentials = false

    @State var showErrorAlert = false

    var body: some View {
        VStack {
            Text("WiFi")
                .font(.title.bold())
                .foregroundStyle(.black)

            Text("Type your WiFi network name and password to connect KiLL to your network.")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)

            TextField("WiFi Network Name", text: $wifiSSID)
                .textFieldStyle(.roundedBorder)
                .colorScheme(.light)

            TextField("WiFi Password", text: $wifiPassword)
                .textFieldStyle(.roundedBorder)
                .colorScheme(.light)

            Button("Send Credentials", action: sendCredentials)
                .buttonStyle(.borderedProminent)
                .tint(.darkKiLLGray)
                .foregroundStyle(.white)
                .disabled(wifiSSID.isReallyEmpty || wifiPassword.isEmpty || sendingCredentials)

            if sendingCredentials {
                ProgressView("Sending credentials... (Attempt \(setupAttempt)/\(maximumAttempts)")
            }
        }
        .foregroundStyle(.gray)
        .padding()
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .alert("Setup Not Successful", isPresented: $showErrorAlert) {
            Button("Retry", role: .cancel, action: retrySetup)
            Button("Cancel", role: .destructive) {
                showErrorAlert = false
                sendingCredentials = false
            }
        } message: {
            Text("Please make sure that KiLL is powered on and you're connected to its network.")
        }
    }

    func sendCredentials() {
        sendingCredentials = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            localNetworkManager.sendSetupCredentials(ssid: wifiSSID, password: wifiPassword, appId: appId)
            if localNetworkManager.setupSuccessfully == true {
                timer.invalidate()
                withAnimation {
                    sendingCredentials = false
                }
            } else if localNetworkManager.setupSuccessfully == false {
                print("Failed send setup credentials attempt \(setupAttempt)")
                if setupAttempt >= maximumAttempts {
                    timer.invalidate()
                    sendingCredentials = false
                    showErrorAlert = true
                } else {
                    setupAttempt += 1
                }
            }
        }
    }

    func retrySetup() {
        sendingCredentials = true
        showErrorAlert = false
        setupAttempt = 1
        sendCredentials()
    }
}

#Preview {
    SetupKiLLWiFiView()
}
