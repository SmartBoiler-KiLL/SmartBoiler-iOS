//
//  PermissionsView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/25/25.
//

import SwiftUI

/// A view that asks for the necessary permissions to setup KiLL.
struct PermissionsView: View {
    
    @State var permissionForLocalNetwork = false
    
    @State var locationPermission = LocationManager()
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Permissions")
                .font(.title)
                .fontWeight(.black)

            Text("Let’s start by giving the app the necessary permissions to setup KiLL")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Group {
                PermissionSection(title: "Local Network", description: "Setup and connect your KiLL to WiFi.", systemImage: "globe", permission: permissionForLocalNetwork, askPermission: askPermissionForLocalNetwork)
                PermissionSection(title: "Location", description: "Save where KiLL is located", systemImage: "mappin", permission: locationPermission.locationPermissionGranted, askPermission: locationPermission.requestPermission)
            }
            .padding()
            .background(.darkKiLLGray)
            .clipShape(.rect(cornerRadius: 24))
            
            if permissionForLocalNetwork && locationPermission.locationPermissionGranted {
                NavigationLink(
                    destination:
                        SetupView(isFirstSetup: true)
                            .navigationBarBackButtonHidden()
                ) {
                    HStack {
                        Text("Setup My First KiLL")
                        Image(systemName: "chevron.right")
                    }
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.darkKiLLGray)
                    .clipShape(.rect(cornerRadius: 16))
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .navigationBarBackButtonHidden()
        .padding()
        .mainBackgroundGradient(alignment: .top)
    }
    
    func askPermissionForLocalNetwork() {
        LocalNetworkPermission().requestPermission { status in
            withAnimation {
                permissionForLocalNetwork = status
            }
        }
    }
}

#Preview {
    PermissionsView()
}
