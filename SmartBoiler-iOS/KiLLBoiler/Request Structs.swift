//
//  Request Structs.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/28/25.
//

struct ServerResponse: Decodable {
    let targetTemperature: Int?
    let currentTemperature: Double?
    let isOn: Int?
    let localIP: String?
    let minimumTemperature: Int?
}

struct KiLLCommand: Encodable {
    let command: String
    let value: Int
}

struct SimpleServerResponse: Decodable {
    let status: String?
    let error: String?
}

struct EmptyEncodable: Encodable {}

enum RequestError: Error {
    case invalidURL
    case missingAppID
    case encodingError
    case cancelled
    case networkError(Error)

    var isCancellation: Bool {
        if case .cancelled = self {
            return true
        }
        return false
    }
}
