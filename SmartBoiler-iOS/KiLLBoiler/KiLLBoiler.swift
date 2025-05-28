//
//  KiLLBoiler.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/26/25.
//

import SwiftData
import SwiftUI
import CoreLocation

@Model
final class KiLLBoiler: Identifiable {
    @Attribute(.unique) var id: String
    var name: String

    var hostname: String {
        "http://KiLL-\(id).local"
    }

    var currentTemperature: Double
    var targetTemperature: Double
    var lastConnection: Date

    private var latitude: Double
    private var longitude: Double

    var location: CLLocationCoordinate2D? {
        latitude != 0 || longitude != 0 ? CLLocationCoordinate2D(latitude: latitude, longitude: longitude) : nil
    }

    init(id: String, name: String, location: CLLocationCoordinate2D?) {
        self.id = id
        self.name = name
        self.currentTemperature = 0
        self.targetTemperature = 0
        self.lastConnection = .now
        self.latitude = location?.latitude ?? 0
        self.longitude = location?.longitude ?? 0
    }

    var status: Status = Status.turnedOff

    enum Status: Int, Codable {
        case disconnected
        case turnedOn
        case turnedOff
        case loading

        var systemImage: String {
            switch self {
            case .disconnected:
                "wifi.exclamationmark.circle.fill"
            case .turnedOn:
                "power.circle.fill"
            case .turnedOff:
                "power.circle"
            case .loading:
                ""
            }
        }
    }

    @MainActor func updateStatus() async {
        guard let url = URL(string: "http://192.168.1.142/status") else { return }
        guard let appId = UserDefaults.standard.string(forKey: "AppID") else { return print("AppID not found") }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode([
                "appId": appId,
                "espId": id
            ])

            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 15
            sessionConfig.timeoutIntervalForResource = 15

            let session = URLSession(configuration: sessionConfig)

            let (data, _) = try await session.data(for: request)

            struct ServerResponse: Decodable {
                let targetTemperature: Double?
                let currentTemperature: Double?
                let isOn: Int?
            }

            let decoded = try JSONDecoder().decode(ServerResponse.self, from: data)

            if let targetTemperature = decoded.targetTemperature, let currentTemperature = decoded.currentTemperature, let isOn = decoded.isOn {
                self.targetTemperature = targetTemperature
                self.currentTemperature = currentTemperature
                self.status = isOn == 1 ? .turnedOn : .turnedOff
                self.lastConnection = .now
            } else {
                print("Invalid response from server for \(name)")
                status = .disconnected
            }
        } catch {
            print("Error updating status for \(name): \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.status = .disconnected
            }
        }
    }
}
