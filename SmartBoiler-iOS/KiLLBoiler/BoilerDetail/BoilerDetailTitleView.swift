//
//  BoilerDetailTitleView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/28/25.
//

import SwiftUI

struct BoilerDetailTitleView: View {

    @Environment(\.dismiss) var dismiss

    @Bindable var viewModel: BoilerViewModel

    @State var showSettings = false

    var body: some View {
        HStack {
            Button("", systemImage: "chevron.left", action: dismiss.callAsFunction)
                .font(.title3)
                .tint(.white)

            Text(viewModel.boiler.name)
                .font(.largeTitle.bold())

            Spacer()

            Button("Settings", systemImage: "gear") {
                showSettings.toggle()
            }
            .labelStyle(.iconOnly)
            .font(.title)
        }
        .sheet(isPresented: $showSettings) {
            BoilerDetailSettingsView(viewModel: viewModel)
                .presentationDetents([.medium])
        }
    }
}
