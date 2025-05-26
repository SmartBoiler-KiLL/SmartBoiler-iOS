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

    var location: CLLocationCoordinate2D

    init(id: String, name: String, location: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.currentTemperature = 0
        self.targetTemperature = 0
        self.lastConnection = .now
        self.location = location
    }
}
