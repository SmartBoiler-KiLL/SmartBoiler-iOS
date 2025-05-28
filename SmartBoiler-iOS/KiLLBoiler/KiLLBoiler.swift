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
    var targetTemperature: Int
    var lastConnection: Date

    @Attribute(.ephemeral) var localIP: String?
    @Attribute(.ephemeral) var status: Status = Status.disconnected

    var failedAttempts = 0

    private var latitude: Double
    private var longitude: Double

    static let failedAttemptsToShowLoading = 2
    static let failedAttemptsToShowDisconnected = 5
    static let minimumTemperature = 23
    static let maximumTemperature = 50

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
    func updateStatus(sendingRequest: Bool) async {
        guard let response: ServerResponse = await postRequest(to: "status") else {
            await MainActor.run {
                if failedAttempts >= Self.failedAttemptsToShowDisconnected {
                    status = .disconnected
                }
                failedAttempts += 1
            }
            return
        }

        if let target = response.targetTemperature,
           let current = response.currentTemperature,
           let isOn = response.isOn,
           let localIP = response.localIP {
            await MainActor.run {
                if sendingRequest { return } // Ignore updates while sending requests
                self.targetTemperature = target
                self.currentTemperature = current
                self.status = isOn == 1 ? .turnedOn : .turnedOff
                self.lastConnection = .now
                self.localIP = localIP
                self.failedAttempts = 0
            }
        } else {
            print("Invalid response from server for \(name)")
            await MainActor.run {
                if failedAttempts >= Self.failedAttemptsToShowDisconnected {
                    status = .disconnected
                }
            }
        }
    }

    @MainActor func toggleBoiler() async {
        guard status != .disconnected else { return }

        let command = KiLLCommand(command: status == .turnedOn ? "turn_off" : "turn_on", value: 0)
        guard let response: SimpleServerResponse = await postRequest(to: "command", with: command) else {
            print("Failed to toggle boiler for \(name)")
            return
        }

        if let status = response.status {
            print("Operation status for \(name): \(status)")
        } else if let error = response.error {
            print("Error toggling boiler for \(name): \(error)")
        } else {
            print("Unexpected response from server for \(name): \(response)")
        }
    }

    // MARK: - Shared POST Request Helper

    private func postRequest<T: Decodable, R: Encodable>(to endpoint: String, with data: R = EmptyEncodable()) async -> T? {
        let urlString = (localIP == nil ? hostname : "http://\(localIP!)") + "/\(endpoint)"
        guard let url = URL(string: urlString) else { return nil }

        guard let appId = UserDefaults.standard.string(forKey: "AppID") else {
            print("AppID not found")
            return nil
        }

        // Start with appId and espId
        var fullDict: [String: Any] = [
            "appId": appId,
            "espId": id
        ]

        // If data exists, merge its keys into the dictionary
        if type(of: data) != EmptyEncodable.self,
           let encodedData = try? JSONEncoder().encode(data),
           let rawDict = try? JSONSerialization.jsonObject(with: encodedData) as? [String: Any] {
            for (key, value) in rawDict {
                fullDict[key] = value
            }
        }

        // Convert fullDict back to JSON for the request body
        guard let bodyData = try? JSONSerialization.data(withJSONObject: fullDict) else {
            print("Failed to encode request body")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 7
        config.timeoutIntervalForResource = 7
        let session = URLSession(configuration: config)

        do {
            let (data, _) = try await session.data(for: request)
            if T.self == String.self, let string = String(data: data, encoding: .utf8) as? T {
                return string
            } else {
                return try JSONDecoder().decode(T.self, from: data)
            }
        } catch {
            print("POST to \(urlString) failed: \(error.localizedDescription)")
            return nil
        }
    }
}
