//
//  BoilerDetailSettingsView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/28/25.
//

import SwiftUI

struct BoilerDetailSettingsView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @Bindable var viewModel: BoilerViewModel

    init(viewModel: BoilerViewModel) {
        self.viewModel = viewModel
    }

    @State var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Current Network") {
                    Picker("Network", selection: $viewModel.boiler.networkSelection) {
                        Text("WiFi").tag(KiLLBoiler.NetworkSelection.wifi)
                        Text("KiLL Network").tag(KiLLBoiler.NetworkSelection.kill)
                    }
                    .pickerStyle(.segmented)
                }

                Section("KiLL Name") {
                    TextField("Name", text: $viewModel.boiler.name)
                }

                Button("Delete & Reset KiLL", role: .destructive) {
                    showDeleteAlert.toggle()
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done", action: dismiss.callAsFunction)
            }
        }
        .alert("Delete & Reset KiLL", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteBoiler(modelContext: modelContext, dismiss: dismiss.callAsFunction)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete the KiLL from the app and reset it to factory settings. Are you sure?")
        }
        .onChange(of: viewModel.boiler.networkSelection) {
            viewModel.boiler.localIP = viewModel.boiler.networkSelection == .kill ? KiLLBoiler.localNetworkIP : nil
        }
    }
}
