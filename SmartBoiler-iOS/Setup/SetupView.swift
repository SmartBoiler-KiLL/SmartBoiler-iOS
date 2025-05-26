//
//  SetupView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/17/25.
//

import SwiftUI

struct SetupView: View {
    
    let isFirstSetup: Bool

    @State var localNetworkManager = LocalNetworkManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("KiLL Setup")
                .font(.largeTitle.bold())
                .padding(.top, isFirstSetup ? 20 : 0)
            
            Group {
                SetupKiLLConnectionView()

                if localNetworkManager.isUsingmDNS {
                    SetupKiLLWiFiView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
            .background(.darkKiLLGray)
            .clipShape(.rect(cornerRadius: 16))
        }
        .environment(localNetworkManager)
        .mainBackgroundGradient(alignment: .top)
        .toolbar {
            if !isFirstSetup {
                Button("Close", systemImage: "xmark") {
                }
                .tint(.white)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SetupView(isFirstSetup: true)
    }
}
