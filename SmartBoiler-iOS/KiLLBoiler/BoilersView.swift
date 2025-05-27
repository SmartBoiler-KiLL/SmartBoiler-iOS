//
//  BoilersView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/26/25.
//

import SwiftUI
import SwiftData

struct BoilersView: View {

    @Environment(\.modelContext) private var modelContext

    var boilers: [KiLLBoiler]

    var body: some View {
        List(boilers) { boiler in
            Text("\(boiler)")
                .contextMenu {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(boiler)
                        try? modelContext.save()
                    }
                }
        }
        .navigationTitle("Boilers")
    }
}
