//
//  SetupView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/17/25.
//

import SwiftUI
import SwiftData

struct SetupView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let isFirstSetup: Bool

    @State var localNetworkManager = LocalNetworkManager()
    @State var locationManager = LocationManager()

    @State var wifiSSID = "INFINITUM0453_2.4"
    @State var kiLLName = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("KiLL Setup")
                    .font(.largeTitle.bold())
                    .padding(.top, isFirstSetup ? 20 : 0)

                Group {
                    SetupKiLLConnectionView()

                    if localNetworkManager.isUsingmDNS {
                        SetupKiLLWiFiView(wifiSSID: $wifiSSID)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if localNetworkManager.setupSuccessfully == true {
                        SetupNameLocation(kiLLName: $kiLLName)
                            .transition(.move(edge: .bottom).combined(with: .opacity))

                        Button("Finish Setup", action: finishSetup)
                            .disabled(kiLLName.isReallyEmpty)
                    }
                }
                .animation(.bouncy, value: localNetworkManager.setupSuccessfully)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.darkKiLLGray)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal)
            }
        }
        .environment(localNetworkManager)
        .environment(locationManager)
        .mainBackgroundGradient(alignment: .top)
        .toolbar {
            if !isFirstSetup {
                Button("Close", systemImage: "xmark") {
                }
                .tint(.white)
            }
        }
    }

    func finishSetup() {
        do {
            let kiLL = KiLLBoiler(id: localNetworkManager.mDNSAddress, name: kiLLName, location: locationManager.getLocation())
            modelContext.insert(kiLL)
            try modelContext.save()

            UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter({ $0.isKeyWindow }).first?.rootViewController?.dismiss(animated: true)
        } catch {
            print("Error saving KiLL: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        SetupView(isFirstSetup: true)
    }
}
