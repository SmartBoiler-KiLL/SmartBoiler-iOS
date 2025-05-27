//
//  SetupNameLocation.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/26/25.
//

import SwiftUI
import MapKit

struct SetupNameLocation: View {
    
    @Environment(LocalNetworkManager.self) var localNetworkManager
    @Environment(LocationManager.self) var locationManager

    @Binding var kiLLName: String

    var location: MKCoordinateRegion? {
        guard let location = locationManager.getLocation() else { return nil }
        return MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    }
    
    var body: some View {
        VStack {
            Text("Name")
                .font(.title.bold())
                .foregroundStyle(.black)
            
            Text("What name do you want to give your KiLL?")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            
            if let location {
                Map(initialPosition: MapCameraPosition.region(location), interactionModes: []) {
                    Marker("KiLL", coordinate: location.center)
                }
                .frame(height: 200)
                .clipShape(.rect(cornerRadius: 12))
                .toolbar(.hidden)
            }
            
            TextField("KiLL Name", text: $kiLLName)
                .textFieldStyle(.roundedBorder)
                .colorScheme(.light)
        }
        .padding()
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
    }
}
