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
    @Binding var sendingRequest: Bool
    @Binding var updateTask: Task<Void, Never>?

    @State var isEnabled = false
    @State var hasGoneToSettings = false
    @State var showingConnectedProgress = false

    var body: some View {
        VStack {
            if boiler.status == .disconnected && boiler.failedAttempts >= KiLLBoiler.failedAttemptsToShowDisconnected {
                errorView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            titleView

            sliderView
        }
        .animation(.bouncy, value: boiler.failedAttempts)
        .padding()
        .mainBackgroundGradient(alignment: .topLeading)
        .toolbar(.hidden)
        .onChange(of: boiler.failedAttempts) {
            if boiler.failedAttempts >= KiLLBoiler.failedAttemptsToShowDisconnected {
                isEnabled = false
            }
        }
    }

    var titleView: some View {
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
    }

    var errorView: some View {
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
                    showingConnectedProgress = true
                }
            }
            .buttonStyle(.borderedProminent)

            if showingConnectedProgress {
                ProgressView()
                    .tint(.white)
            }
        }
        .padding(.vertical, 5)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(LinearGradient(colors: [.secondaryKiLL, .secondary.opacity(0.3)], startPoint: .top, endPoint: .bottom))
        .clipShape(.rect(cornerRadius: 10))
        .onDisappear {
            showingConnectedProgress = false
            hasGoneToSettings = false
        }
    }

    var sliderView: some View {
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

                Text("\(boiler.targetTemperature)°C")
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
                    Text("\(boiler.currentTemperature, format: .number.precision(.fractionLength(1)))°C")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(.secondaryKiLL)

                    if boiler.failedAttempts >= KiLLBoiler.failedAttemptsToShowLoading {
                        ProgressView()
                            .tint(.secondaryKiLL)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)

            Spacer()

            TemperatureSlider(targetTemperature: $boiler.targetTemperature, isEnabled: isEnabled)
            .sensoryFeedback(.increase, trigger: boiler.targetTemperature)
            .offset(x: 20)
        }
    }
}

#Preview {
    BoilerView(boiler: KiLLBoiler(id: "1", name: "Preview Boiler", location: nil), sendingRequest: .constant(false), updateTask: .constant(nil))
        .colorScheme(.dark)
}
