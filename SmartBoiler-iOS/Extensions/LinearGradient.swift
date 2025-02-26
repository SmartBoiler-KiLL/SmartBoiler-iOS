//
//  LinearGradient.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/25/25.
//

import SwiftUI

extension LinearGradient {
    static let backgroundGradient = LinearGradient(stops: [.init(color: .topGradient, location: 0), .init(color: .bottomGradient, location: 0.64)], startPoint: .top, endPoint: .bottom)
}
