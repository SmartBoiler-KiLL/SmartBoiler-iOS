//
//  SetupKiLLWiFi.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/24/25.
//

import SwiftUI

struct SetupKiLLWiFiView: View {

    @Environment(LocalNetworkManager.self) var localNetworkManager

    @AppStorage("AppID") var appId = ""

    @Binding var wifiSSID: String
    @State var wifiPassword = "7WNr3uRwH4"

    @State var sendingCredentials = false

    @State var showErrorAlert = false
    @State var errorMessage = ""

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
                .disabled(wifiSSID.isReallyEmpty || wifiPassword.isEmpty)

            if sendingCredentials {
                ProgressView("Trying to connect to \(wifiSSID)\nThis may take up to 30 seconds...")
                    .tint(.darkKiLLGray)
                    .multilineTextAlignment(.center)
            }
        }
        .disabled(localNetworkManager.setupSuccessfully == true || sendingCredentials)
        .foregroundStyle(.gray)
        .padding()
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .alert("Setup Not Successful", isPresented: $showErrorAlert) {
            Button("Retry", role: .cancel, action: retrySetup)
            Button("Edit Info") {
                showErrorAlert = false
                sendingCredentials = false
            }
        } message: {
            Text(errorMessage)
        }
    }

    func sendCredentials() {
        Task {
            sendingCredentials = true
            if let error = await localNetworkManager.sendSetupCredentials(ssid: wifiSSID, password: wifiPassword, appId: appId) {
                errorMessage = error
                showErrorAlert = true
            } else {
                print("Successfully sent credentials to KiLL.")
            }
            sendingCredentials = false
        }
    }

    func retrySetup() {
        errorMessage = ""
        sendingCredentials = true
        showErrorAlert = false
        sendCredentials()
    }
}
