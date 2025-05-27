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
}
