//
//  BoilerView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/12/25.
//

import SwiftUI

/// A view to control the boiler.
struct BoilerView: View {

    @Environment(\.dismiss) var dismiss

    @Bindable var boiler: KiLLBoiler

    @State var isEnabled = false
    @State var hasGoneToSettings = false

    let minimumTemperature = 23
    let maximumTemperature = 50

    var body: some View {
        VStack {
            if boiler.status == .disconnected {
                VStack {
                    Text("We can't seem to find your KiLL. If you're at home, you can connect to it using its network.")

                    Button(hasGoneToSettings ? "I'm Connected" : "Open Settings") {
                        if !hasGoneToSettings {
                            if let url = URL(string: "App-prefs:WIFI") {
                                UIApplication.shared.open(url)
                                hasGoneToSettings = true
                            }
                        } else {
                            boiler.localIP = "192.168.39.12"
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(LinearGradient(colors: [.secondaryKiLL, .secondary.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                .clipShape(.rect(cornerRadius: 10))
            }

            HStack {
                Button("", systemImage: "chevron.left", action: dismiss.callAsFunction)
                    .font(.title3)
                    .tint(.white)

                Text(boiler.name)
                    .font(.largeTitle.bold())

                Spacer()

                Button("Settings", systemImage: "gear") {

                }
                .labelStyle(.iconOnly)
                .font(.title)
            }

            HStack {
                VStack(alignment: .leading) {
                    Button("Turn \(isEnabled ? "Off" : "On")", systemImage: isEnabled ? "power.circle.fill" : "power.circle") {
                        isEnabled.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .font(.system(size: 85))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 55)
                    .sensoryFeedback(.increase, trigger: isEnabled)

                    Text("\(boiler.targetTemperature, format: .number.precision(.fractionLength(1)))°C")
                        .font(.system(size: 85, weight: .heavy))
                        .lineLimit(1)
                        .minimumScaleFactor(0.00001)
                        .foregroundStyle(.white)
                        .padding(.top, 55)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 135)

                    Text("CURRENT")
                        .foregroundStyle(.secondaryKiLL)
                    Text("\(boiler.currentTemperature, format: .number.precision(.fractionLength(1)))°C")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(.secondaryKiLL)
                }
                .frame(maxHeight: .infinity, alignment: .top)

                Spacer()

                TemperatureSlider(targetTemperature: .init(get: {
                    Int(boiler.targetTemperature)
                }, set: {
                    boiler.targetTemperature = Double($0)
                }), isEnabled: isEnabled, minimumTemperature: minimumTemperature)
                .sensoryFeedback(.increase, trigger: boiler.targetTemperature)
                .offset(x: 20)
            }
        }
        .padding()
        .mainBackgroundGradient(alignment: .topLeading)
        .toolbar(.hidden)
    }

    var sliderView: some View {
        EmptyView()
    }
}

#Preview {
    BoilerView(boiler: KiLLBoiler(id: "1", name: "Preview Boiler", location: nil))
        .colorScheme(.dark)
}
