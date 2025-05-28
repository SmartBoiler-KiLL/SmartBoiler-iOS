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

    @Attribute(.ephemeral) var localIP: String?

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

    @Attribute(.ephemeral) var status: Status = Status.disconnected

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

    @MainActor
    func getLocalIP() async {
        guard let response: String = await postRequest(to: "\(hostname)/local_ip") else {
            self.status = .disconnected
            return
        }
        self.localIP = response
        print("Local IP for \(name): \(response)")
    }

    @MainActor
    func updateStatus() async {
        guard let localIP else { return }
        struct ServerResponse: Decodable {
            let targetTemperature: Double?
            let currentTemperature: Double?
            let isOn: Int?
        }

        guard let response: ServerResponse = await postRequest(to: "http://\(localIP)/status") else {
            status = .disconnected
            return
        }

        if let target = response.targetTemperature,
           let current = response.currentTemperature,
           let isOn = response.isOn {
            self.targetTemperature = target
            self.currentTemperature = current
            self.status = isOn == 1 ? .turnedOn : .turnedOff
            self.lastConnection = .now
        } else {
            print("Invalid response from server for \(name)")
            status = .disconnected
        }
    }

    // MARK: - Shared POST Request Helper

    private func postRequest<T: Decodable>(to endpoint: String) async -> T? {
        guard let url = URL(string: endpoint) else { return nil }
        guard let appId = UserDefaults.standard.string(forKey: "AppID") else {
            print("AppID not found")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["appId": appId, "espId": id])

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        let session = URLSession(configuration: config)

        do {
            let (data, _) = try await session.data(for: request)
            // If T is String, decode manually
            if T.self == String.self, let string = String(data: data, encoding: .utf8) as? T {
                return string
            } else {
                return try JSONDecoder().decode(T.self, from: data)
            }
        } catch {
            print("POST to \(endpoint) failed: \(error.localizedDescription)")
            return nil
        }
    }
}
