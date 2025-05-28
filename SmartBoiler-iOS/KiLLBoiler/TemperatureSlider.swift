
//  TemperatureSlider.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/12/25.
//

import SwiftUI

/// The temperature slider used in the boiler view.

struct TemperatureSlider: View {
    
    @Binding var targetTemperature: Int
    var isEnabled: Bool
    let minimumTemperature: Int
    let maxTemperature: Int = 50
    
    let curveWidth: CGFloat = -30
    let curveHeight: CGFloat = 75
    
    @State var highlightY = CGFloat.zero
    @State var circleOffset = CGFloat.zero
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if isEnabled {
                    HighlightRuler(height: geometry.size.height - 50)
                        .padding(.trailing)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                
                HighlightCurve(height: geometry.size.height)
                    .frame(width: 1)
                
                Circle()
                    .fill(isEnabled ? .accent : .secondaryKiLL)
                    .frame(width: 50, height: 50)
                    .overlay {
                        VStack(spacing: 0) {
                            Image(systemName: "arrowtriangle.up.fill")
                            Image(systemName: "arrowtriangle.down.fill")
                        }
                    }
                    .offset(y: circleOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let y = value.location.y
                                targetTemperature = Int(map(Int(geometry.size.height) - Int(y), from: 0...Int(geometry.size.height), to: minimumTemperature...maxTemperature))
                                targetTemperature = constrain(targetTemperature, min: minimumTemperature, max: maxTemperature)
                                
                                highlightY = constrain(y, min: curveHeight / 2, max: geometry.size.height - curveHeight / 2)
                                
                                circleOffset = highlightY - 25
                            }
                    )
                    .frame(height: geometry.size.height, alignment: .top)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                // Set the initial position of the circle and highlight curve
                let y = Double(map(targetTemperature, from: minimumTemperature...maxTemperature, to: 0...Int(geometry.size.height)))
                circleOffset = constrain(y, min: curveHeight / 2, max: geometry.size.height - curveHeight / 2) - 25
                highlightY = constrain(y, min: curveHeight / 2, max: geometry.size.height - curveHeight / 2)
            }
        }
        .disabled(!isEnabled)
        .animation(.bouncy, value: isEnabled)
    }
    
    @ViewBuilder
    func HighlightCurve(height: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            
            // Line to the top of the highlight
            path.addLine(to: CGPoint(x: 0, y: highlightY - curveHeight / 2))
            
            // First half of the curve (going out)
            path.addCurve(
                to: CGPoint(x: curveWidth, y: highlightY),
                control1: CGPoint(x: 0, y: highlightY - curveHeight / 3),
                control2: CGPoint(x: curveWidth, y: highlightY - curveHeight / 4)
            )
            
            // Second half of the curve (going in)
            path.addCurve(
                to: CGPoint(x: 0, y: highlightY + curveHeight / 2),
                control1: CGPoint(x: curveWidth, y: highlightY + curveHeight / 4),
                control2: CGPoint(x: 0, y: highlightY + curveHeight / 3)
            )
            
            // Line to the bottom
            path.addLine(to: CGPoint(x: 0, y: height))
        }
        .stroke(isEnabled ? .accent : .secondaryKiLL, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
        .shadow(color: .accent, radius: isEnabled ? 5 : 0)
    }
    
    @ViewBuilder
    func HighlightRuler(height: CGFloat) -> some View {
        let step = 5
        let minorStep = 1
        let totalSteps = Int(Double((maxTemperature - minimumTemperature)) / Double(minorStep))
        let stepHeight = height / CGFloat(totalSteps)
        
        VStack(spacing: 0) {
            ForEach(0...totalSteps, id: \.self) { index in
                let yPos = CGFloat(index) * stepHeight
                let curveEffect = curveOffset(for: yPos, center: highlightY, height: curveHeight, width: curveWidth)
                
                VStack(spacing: 0) {
                    // Big step
                    if index % step == 0 {
                        HStack(alignment: .center) {
                            Text("\(Int(maxTemperature) - index)")
                                .font(.system(size: 16, weight: .light))
                                .foregroundStyle(.secondaryKiLL)
                            
                            Rectangle()
                                .fill(.secondaryKiLL)
                                .frame(width: 25, height: 3)
                        }
                        .offset(x: curveEffect)
                        .frame(height: stepHeight)
                    } else {
                        // Small step
                        Rectangle()
                            .fill(.secondaryKiLL)
                            .frame(width: index % (step / 2) == 0 ? 20 : 10, height: 2)
                            .offset(x: curveEffect)
                            .padding(.trailing, 5)
                            .frame(height: stepHeight)
                    }
                }
            }
        }
        .frame(width: 55, height: height - 50)
    }

    /// Calculate the horizontal offset to simulate the curve
    func curveOffset(for y: CGFloat, center: CGFloat, height: CGFloat, width: CGFloat) -> CGFloat {
        let distance = abs(y - center)
        // Dont't apply curve effect if the distance is greater than the curve height
        if distance > height / 2 {
            return 0
        }
        
        // Normalize the distance to 0-1
        let normalized = (distance / (height / 2))
        // Smooth the curve
        return width * (1 - pow(normalized, 2))
    }
}

#Preview {
    BoilerView(boiler: KiLLBoiler(id: "1", name: "Preview Boiler", location: nil))
}
