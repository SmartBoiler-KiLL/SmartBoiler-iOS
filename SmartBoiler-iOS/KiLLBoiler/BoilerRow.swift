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

    @State var isMainViewActive = false
    @State var sendingRequest = false
    @State var updateTask: Task<Void, Never>? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            if let location {
                Map(initialPosition: MapCameraPosition.region(location), interactionModes: []) {
                    Marker("KiLL", coordinate: location.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            }

            HStack {
                Text(boiler.name)
                    .font(.system(size: 28, weight: .bold))
                    .padding(5)

                Spacer()


                if boiler.status == .disconnected || sendingRequest || boiler.failedAttempts >= 2 {
                    ProgressView()
                        .tint(.white)
                }

                if boiler.status != .disconnected {
                    Text("\(boiler.currentTemperature, format: .number.precision(.fractionLength(1)))°C")
                        .font(.system(size: 28, weight: .bold))
                }

                Button("", systemImage: boiler.status.systemImage) {
                    sendingRequest = true
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
        .onTapGesture {
            isMainViewActive = true
        }
        .navigationDestination(isPresented: $isMainViewActive) {
            BoilerView(boiler: boiler, sendingRequest: $sendingRequest, updateTask: $updateTask)
        }
        .task {
            keepBoilerUpdated()
        }
        .onChange(of: isMainViewActive) {
            if !isMainViewActive {
                keepBoilerUpdated()
            }
        }
        .onChange(of: sendingRequest) {
            if sendingRequest {
                updateTask?.cancel()
            } else {
                keepBoilerUpdated()
            }
        }
    }

    func keepBoilerUpdated() {
        updateTask?.cancel()

        updateTask = Task {
            while !Task.isCancelled {
                if sendingRequest {
                    print("Request in progress — cancelling current update loop")
                    break
                }

                await boiler.updateStatus()
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }
}
