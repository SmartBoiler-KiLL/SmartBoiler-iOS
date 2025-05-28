//
//  LocalNetworkManager.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/24/25.
//

import SwiftUI

@Observable class LocalNetworkSetupManager {
    private let ipAddress = "192.168.39.12"

    var mDNSAddress = ""
    var isUsingmDNS = false
    var setupSuccessfully: Bool? = nil

    var stringURL: String {
        if isUsingmDNS {
            return "http://KiLL-\(mDNSAddress).local"
        } else {
            return "http://\(ipAddress)"
        }
    }

    func getLocalmDNS() {
        Task {
            do {
                let response = try await URLSession.shared.data(from: URL(string: "http://\(ipAddress)/local")!)
                if let result = String(data: response.0, encoding: .utf8) {
                    if result.count == 12 {
                        print("mDNS URL: \(result)")
                        withAnimation(.bouncy) {
                            mDNSAddress = result
                            isUsingmDNS = true
                        }
                    } else {
                        print("Different URL: \(result)")
                    }
                } else {
                    isUsingmDNS = false
                }
            } catch {
                print("Error fetching local mDNS: \(error)")
            }
        }
    }

    func sendSetupCredentials(ssid: String, password: String, appId: String) async -> String? {
        await UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        guard let url = URL(string: "\(stringURL)/setup") else {
            return "Invalid URL"
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode([
                "ssid": ssid,
                "password": password,
                "appId": appId
            ])
        } catch {
            return "Failed to encode JSON: \(error.localizedDescription)"
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 40
        sessionConfig.timeoutIntervalForResource = 40
        let session = URLSession(configuration: sessionConfig)

        do {
            let (data, _) = try await session.data(for: request)

            struct ServerResponse: Decodable {
                let status: String?
                let error: String?
            }

            let decoded = try JSONDecoder().decode(ServerResponse.self, from: data)

            if let status = decoded.status, status == "OK" {
                setupSuccessfully = true
                return nil
            } else if let errorMessage = decoded.error {
                setupSuccessfully = false
                return errorMessage
            } else {
                setupSuccessfully = false
                return "Unexpected server response"
            }

        } catch {
            setupSuccessfully = false
            return "Network error: \(error.localizedDescription)"
        }
    }
}
