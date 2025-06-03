//
//  BoilerDetailSliderView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/28/25.
//

import SwiftUI

struct BoilerDetailSliderView: View {

    @Bindable var viewModel: BoilerViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Button(
                    "Turn \(viewModel.boilerStatus == .turnedOn ? "Off" : "On")",
                    systemImage: viewModel.boilerStatus == .turnedOn ? "power.circle.fill" : "power.circle",
                    action: viewModel.toggleBoiler
                )
                .disabled(viewModel.boilerStatus == .disconnected)
                .labelStyle(.iconOnly)
                .font(.system(size: 85))
                .foregroundStyle(.white)
                .overlay {
                    if viewModel.sendingRequest {
                        ProgressView()
                            .dynamicTypeSize(.xLarge)
                            .tint(.secondaryKiLL)
                            .padding()
                            .background(viewModel.boilerStatus == .turnedOn ? .white : .darkKiLLGray)
                            .clipShape(.circle)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 55)
                .sensoryFeedback(.increase, trigger: viewModel.boilerStatus)
                .animation(.bouncy, value: viewModel.sendingRequest)

                Text("\(viewModel.boilerTargetTemperature)°C")
                    .font(.system(size: 85, weight: .heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.00001)
                    .foregroundStyle(.white)
                    .padding(.top, 55)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 135)

                Text("CURRENT")
                    .foregroundStyle(.secondaryKiLL)

                HStack {
                    Text("\(viewModel.boilerCurrentTemperature, format: .number.precision(.fractionLength(1)))°C")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(.secondaryKiLL)

                    if viewModel.boilerFailedAttempts >= KiLLBoiler.failedAttemptsToShowLoading {
                        ProgressView()
                            .tint(.secondaryKiLL)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)

            Spacer()

            TemperatureSlider(targetTemperature: $viewModel.boiler.targetTemperature, isEnabled: viewModel.boilerStatus == .turnedOn, minimumTemperature: viewModel.boiler.minimumTemperature)
                .sensoryFeedback(.increase, trigger: viewModel.boilerTargetTemperature)
            .offset(x: 20)
        }
    }
}
