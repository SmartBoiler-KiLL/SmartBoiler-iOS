//
//  BoilerRow.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/27/25.
//

import SwiftUI
import MapKit

struct BoilerRow: View {

    @Bindable var boiler: KiLLBoiler

    var location: MKCoordinateRegion? {
        guard let location = boiler.location else { return nil }
        return MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    }

    @State var sendingRequest = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if let location {
                Map(initialPosition: MapCameraPosition.region(location), interactionModes: []) {
                    Marker("KiLL", coordinate: location.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
            }

            HStack {
                Text(boiler.name)
                    .font(.system(size: 28, weight: .bold))
                    .padding(5)

                Spacer()


                if boiler.status == .disconnected || sendingRequest {
                    ProgressView()
                        .tint(.white)
                }

                if boiler.status != .disconnected {
                    Text("\(boiler.currentTemperature, format: .number.precision(.fractionLength(1)))°C")
                        .font(.system(size: 28, weight: .bold))
                }

                Button("", systemImage: boiler.status.systemImage) {

                }
                .font(.title2.bold())
                .foregroundStyle(boiler.status == .disconnected ? .red : .white)
                .animation(.bouncy, value: boiler.status)
            }
            .foregroundStyle(.white)
            .font(.system(size: 28, weight: .bold))
            .background(LinearGradient(colors: [.darkKiLLGray, .darkKiLLGray.opacity(0.2)], startPoint: .bottom, endPoint: .top))
        }
        .clipShape(.rect(cornerRadius: 12))
        .task {
            while true {
                if !sendingRequest {
                    if boiler.localIP == nil {
                        await boiler.getLocalIP()
                    } else {
                        await boiler.updateStatus()
                    }
                }
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }
}
