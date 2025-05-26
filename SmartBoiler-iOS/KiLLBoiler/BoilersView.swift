//
//  BoilersView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/26/25.
//

import SwiftUI

struct BoilersView: View {

    var boilers: [KiLLBoiler]

    var body: some View {
        List(boilers) { boiler in
            Text("\(boiler)")
        }
        .navigationTitle("Boilers")
    }
}
