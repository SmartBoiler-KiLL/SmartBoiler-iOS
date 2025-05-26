//
//  LocalNetworkManager.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/24/25.
//

import SwiftUI

@Observable class LocalNetworkManager {
    private let ipAddress = "192.168.39.12"

    var mDNSAddress = ""
    var isUsingmDNS = false
    var setupSuccessfully: Bool? = nil

    var stringURL: String {
        if isUsingmDNS {
            return "http://\(mDNSAddress).local"
        } else {
            return "http://\(ipAddress)"
        }
    }

    func getLocalmDNS() {
        Task {
            do {
                let response = try await URLSession.shared.data(from: URL(string: "http://\(ipAddress)/local")!)
                if let result = String(data: response.0, encoding: .utf8) {
                    if result.starts(with: "KiLL-") {
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

    func sendSetupCredentials(ssid: String, password: String, appId: String) {
        Task {
            do {
                let url = URL(string: "\(stringURL)/setup")!
                var request = URLRequest(url: url)
                request.httpBody = try JSONEncoder().encode(["ssid": ssid, "password": password, "appId": appId])
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let (data, _) = try await URLSession.shared.data(for: request)

                struct ServerResponse: Decodable {
                    let status: String?
                    let error: String?
                }

                let decoded = try JSONDecoder().decode(ServerResponse.self, from: data)

                if let status = decoded.status, status == "OK" {
                    print("Setup credentials sent successfully.")
                    setupSuccessfully = true
                } else if let errorMessage = decoded.error {
                    print("Error sending setup credentials: \(errorMessage)")
                    setupSuccessfully = false
                } else {
                    print("Unexpected response from server.")
                    setupSuccessfully = false
                }
            } catch {
                print("Error sending setup credentials: \(error)")
                setupSuccessfully = false
            }
        }
    }

}

