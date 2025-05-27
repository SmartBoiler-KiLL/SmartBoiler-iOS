//
//  LocationPermission.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/12/25.
//

import SwiftUI
import CoreLocation

/// Class that manages the location (permission and updates) of the device.
@Observable class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager
    var locationPermissionGranted = false
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    /// Request the permission to use the location of the device.
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func getLocation() -> CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    /// Update the permission granted status.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        withAnimation {
            locationPermissionGranted = manager.authorizationStatus != .denied && manager.authorizationStatus != .notDetermined
        }
    }
}
