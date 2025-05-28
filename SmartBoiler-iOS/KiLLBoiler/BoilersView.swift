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

    var boilerList: [KiLLBoiler] {
        boilers.filter { filter.isReallyEmpty || $0.name.localizedCaseInsensitiveContains(filter) }
    }

    @State var showAddBoiler = false
    @State var filter = ""

    var body: some View {
        List(boilerList) { boiler in
            BoilerRow(boiler: boiler)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .padding(.top, 5)
        .scrollContentBackground(.hidden)
        .mainBackgroundGradient()
        .navigationTitle("KiLLs")
        .searchable(text: $filter, prompt: "Search")
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
