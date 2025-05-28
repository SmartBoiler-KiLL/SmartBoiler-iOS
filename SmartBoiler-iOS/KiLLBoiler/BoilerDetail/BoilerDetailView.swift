//
//  BoilerView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/12/25.
//

import SwiftUI

/// A view to control the boiler.
struct BoilerDetailView: View {

    @Environment(\.dismiss) var dismiss

    @Bindable var viewModel: BoilerViewModel

    @State var hasGoneToSettings = false
    @State var showingConnectedProgress = false

    var body: some View {
        VStack {
            if viewModel.boilerStatus == .disconnected && viewModel.boilerFailedAttempts >= KiLLBoiler.failedAttemptsToShowDisconnected {
                BoilerDetailNetworkErrorView(viewModel: viewModel, hasGoneToSettings: $hasGoneToSettings, showingConnectedProgress: $showingConnectedProgress)
            }

            BoilerDetailTitleView(viewModel: viewModel)

            BoilerDetailSliderView(viewModel: viewModel)
        }
        .animation(.bouncy, value: viewModel.boilerFailedAttempts)
        .padding()
        .mainBackgroundGradient(alignment: .topLeading)
        .toolbar(.hidden)
    }
}
