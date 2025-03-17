//
//  BoilerView.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/12/25.
//

import SwiftUI

/// A view to control the boiler.
struct BoilerView: View {
    
    let boilerTitle = "UABC's KiLL"
    let minimumTemperature = 23
    
    @State var isEnabled = false
    @State var hasNetworkError = false
    @State var currentTemperature = 23
    @State var targetTemperature = 39
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(boilerTitle)
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
                    
                    Text("\(targetTemperature)°")
                        .contentTransition(.numericText())
                        .transaction { $0.animation = .bouncy }
                        .font(.system(size: 85, weight: .heavy))
                        .lineLimit(1)
                        .minimumScaleFactor(0.00001)
                        .foregroundStyle(.white)
                        .padding(.top, 55)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 135)
                    
                    Text("CURRENT")
                        .foregroundStyle(.secondaryKiLL)
                    Text("\(currentTemperature)°")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(.secondaryKiLL)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                Spacer()
                
                TemperatureSlider(targetTemperature: $targetTemperature, isEnabled: isEnabled, minimumTemperature: minimumTemperature)
                    .sensoryFeedback(.increase, trigger: targetTemperature)
                    .offset(x: 20)
            }
        }
        .padding()
        .mainBackgroundGradient(alignment: .topLeading)
    }
}

#Preview {
    BoilerView()
}
