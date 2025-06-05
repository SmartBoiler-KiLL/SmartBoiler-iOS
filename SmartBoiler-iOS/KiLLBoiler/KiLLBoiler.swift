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
    var minimumTemperature: Int = 0
    var log = ""

    @Attribute(.ephemeral) var localIP: String?
    @Attribute(.ephemeral) var status: Status = Status.disconnected
    @Attribute(.ephemeral) var failedAttempts = 2 // Start with 2 to show loading state initially
    @Attribute(.ephemeral) var networkSelection: NetworkSelection? = NetworkSelection.kill

    private var latitude: Double
    private var longitude: Double

    static let failedAttemptsToShowLoading = 2
    static let failedAttemptsToShowDisconnected = 5
    static let maximumTemperature = 65
    static let localNetworkIP = "192.168.39.12"

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

    enum NetworkSelection: Int8, Codable {
        case kill
        case wifi
    }

    @MainActor
    func updateStatus(sendingRequest: Bool) async {
        let result = await postRequest(to: "status") as Result<ServerResponse, RequestError>
        
        switch result {
        case .success(let response):
            if let target = response.targetTemperature,
               let current = response.currentTemperature,
               let isOn = response.isOn,
               let localIP = response.localIP,
               let minimumTemperature = response.minimumTemperature
            {
                await MainActor.run {
                    if sendingRequest { return } // Ignore updates while sending requests
                    print("Status update for \(name): target=\(target), current=\(current), isOn=\(isOn), localIP=\(localIP), minimumTemperature=\(minimumTemperature)")
                    if target >= self.minimumTemperature && target <= Self.maximumTemperature {
//                        self.targetTemperature = target
                    }
                    self.currentTemperature = current
                    self.status = isOn == 1 ? .turnedOn : .turnedOff
                    self.lastConnection = .now
//                    self.localIP = localIP
                    self.networkSelection = localIP == Self.localNetworkIP ? .kill : .wifi
                    self.failedAttempts = 0
                    self.minimumTemperature = minimumTemperature
                }
            } else {
                print("Invalid response from server for \(name)")
                await MainActor.run {
                    if failedAttempts >= Self.failedAttemptsToShowDisconnected {
                        status = .disconnected
                    }
                    failedAttempts += 1
                }
            }
            
        case .failure(let error):
            await MainActor.run {
                if !error.isCancellation {
                    print("Failed to fetch status for \(name): \(error.localizedDescription)")
                    if failedAttempts >= Self.failedAttemptsToShowDisconnected {
                        status = .disconnected
                    }
                    failedAttempts += 1
                }
            }
        }
    }

    @MainActor func toggleBoiler() async {
        guard status != .disconnected else { return }

        let command = KiLLCommand(command: status == .turnedOn ? "turn_off" : "turn_on", value: 0)
        let result = await postRequest(to: "command", with: command) as Result<SimpleServerResponse, RequestError>
        
        switch result {
        case .success(let response):
            if let status = response.status {
                print("Operation status for \(name): \(status)")
                await MainActor.run {
                    self.status = self.status == .turnedOn ? .turnedOff : .turnedOn
                }
            } else if let error = response.error {
                print("Error toggling boiler for \(name): \(error)")
            } else {
                print("Unexpected response from server for \(name): \(response)")
            }
        case .failure(let error):
            print("Failed to toggle boiler for \(name): \(error)")
        }
    }

    @MainActor func setTargetTemperature() async {
        print("Setting target temperature for \(name): \(targetTemperature)°C")
        let command = KiLLCommand(command: "set_temperature", value: targetTemperature)

        let result = await postRequest(to: "command", with: command) as Result<SimpleServerResponse, RequestError>
        
        switch result {
        case .success(let response):
            if let status = response.status, status == "OK" {
                print("Target temperature set successfully for \(name)")
            } else if let error = response.error {
                print("Error setting target temperature for \(name): \(error)")
            } else {
                print("Unexpected response from server for \(name): \(response)")
            }
        case .failure(let error):
            print("Failed to set target temperature for \(name): \(error)")
        }
    }

    @MainActor func resetKiLL() async -> Bool {
        let result = await postRequest(to: "kill_reset_factory") as Result<SimpleServerResponse, RequestError>
        
        switch result {
        case .success(let response):
            return response.status == "OK"
        case .failure(let error):
            print("Failed to reset KiLL for \(name): \(error)")
            return false
        }
    }

    // MARK: - Shared POST Request Helper

    private func postRequest<T: Decodable, R: Encodable>(to endpoint: String, with data: R = EmptyEncodable()) async -> Result<T, RequestError> {
        let urlString = "http://192.168.39.12/" + "\(endpoint)"
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        guard let appId = UserDefaults.standard.string(forKey: "AppID") else {
            print("AppID not found")
            return .failure(.missingAppID)
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
            return .failure(.encodingError)
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
                return .success(string)
            } else {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return .success(decodedData)
            }
        } catch {
            print("POST to \(urlString) failed: \(error.localizedDescription)")
            
            // Check if the error is due to cancellation
            if let urlError = error as? URLError, urlError.code == .cancelled {
                return .failure(.cancelled)
            } else {
                return .failure(.networkError(error))
            }
        }
    }
}

