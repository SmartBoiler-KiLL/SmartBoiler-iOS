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

    @State var showAddBoiler = false

    var body: some View {
        List(boilers) { boiler in
            Text("\(boiler.id) \(boiler.name)")
                .contextMenu {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(boiler)
                        try? modelContext.save()
                    }
                }
        }
        .scrollContentBackground(.hidden)
        .mainBackgroundGradient()
        .navigationTitle("Boilers")
        .toolbar {
            Button("Add KiLL", systemImage: "gauge.with.dots.needle.bottom.50percent.badge.plus") {
                showAddBoiler.toggle()
            }
            .tint(.white)
        }
        .fullScreenCover(isPresented: $showAddBoiler) {
            SetupView(isFirstSetup: false)
        }
    }
}
