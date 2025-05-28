//
//  BoilerViewModel.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/28/25.
//

import SwiftUI
import MapKit

@Observable
final class BoilerViewModel {
    var boiler: KiLLBoiler
    var isMainViewActive = false
    var sendingRequest = false
    var updateTask: Task<Void, Never>? = nil

    init(boiler: KiLLBoiler) {
        self.boiler = boiler
    }

    var region: MKCoordinateRegion? {
        guard let location = boiler.location else { return nil }
        return MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    }

    // MARK: Getters & Setters

    var boilerStatus: KiLLBoiler.Status {
        boiler.status
    }

    var boilerFailedAttempts: Int {
        boiler.failedAttempts
    }

    var boilerTargetTemperature: Int {
        boiler.targetTemperature
    }

    var boilerCurrentTemperature: Double {
        boiler.currentTemperature
    }

    func setBoilerIP(_ ip: String) {
        boiler.localIP = ip
    }

    // MARK: Network actions
    func keepBoilerUpdated() {
        updateTask?.cancel()

        updateTask = Task {
            while !Task.isCancelled {
                if sendingRequest {
                    print("Request in progress — cancelling current update loop")
                    break
                }

                await boiler.updateStatus(sendingRequest: sendingRequest)
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    func toggleBoiler() {
        if boiler.status == .disconnected || sendingRequest { return }
        Task {
            sendingRequest = true
            await boiler.toggleBoiler()
            sendingRequest = false
        }
    }
}
