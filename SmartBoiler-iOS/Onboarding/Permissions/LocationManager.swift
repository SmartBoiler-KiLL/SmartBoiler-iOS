//
//  LocationPermission.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/12/25.
//

import SwiftUI
import CoreLocation

@Observable class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager
    var locationPermissionGranted = false
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        withAnimation {
            locationPermissionGranted = manager.authorizationStatus != .denied && manager.authorizationStatus != .notDetermined
        }
    }
}
