//
//  BoilerRow.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/27/25.
//

import SwiftUI
import MapKit

struct BoilerRow: View {

    @Bindable var boiler: KiLLBoiler

    @State var viewModel: BoilerViewModel

    init(boiler: KiLLBoiler) {
        self.boiler = boiler
        self.viewModel = BoilerViewModel(boiler: boiler)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if let region = viewModel.region {
                Map(initialPosition: MapCameraPosition.region(region), interactionModes: []) {
                    Marker(boiler.name, coordinate: region.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            }

            HStack {
                Text(boiler.name)
                    .font(.system(size: 28, weight: .bold))
                    .padding(5)

                Spacer()


                if boiler.status == .disconnected || viewModel.sendingRequest || boiler.failedAttempts >= KiLLBoiler.failedAttemptsToShowLoading {
                    ProgressView()
                        .tint(.white)
                }

                if boiler.status != .disconnected {
                    Text("\(boiler.currentTemperature, format: .number.precision(.fractionLength(1)))°C")
                        .font(.system(size: 28, weight: .bold))
                }

                Image(systemName: boiler.status.systemImage)
                    .font(.title.bold())
                    .foregroundStyle(boiler.status == .disconnected ? .red : .white)
                    .animation(.bouncy, value: boiler.status)
                    .onTapGesture(perform: viewModel.toggleBoiler)
                    .padding(.trailing, 5)
            }
            .foregroundStyle(.white)
            .font(.system(size: 28, weight: .bold))
            .background(LinearGradient(colors: [.darkKiLLGray, .darkKiLLGray.opacity(0.2)], startPoint: .bottom, endPoint: .top))
        }
        .clipShape(.rect(cornerRadius: 12))
        .onTapGesture {
            viewModel.isMainViewActive = true
        }
        .navigationDestination(isPresented: $viewModel.isMainViewActive) {
            BoilerDetailView(viewModel: viewModel)
        }
        .task {
            viewModel.keepBoilerUpdated()
        }
        .onChange(of: viewModel.isMainViewActive) {
            if !viewModel.isMainViewActive {
                viewModel.keepBoilerUpdated()
            }
        }
        .onChange(of: viewModel.sendingRequest) {
            if viewModel.sendingRequest {
                viewModel.updateTask?.cancel()
            } else {
                viewModel.keepBoilerUpdated()
            }
        }
    }
}
