//
//  OnboardingHero.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/25/25.
//

import SwiftUI

/// The hero view of the onboarding screen.
struct OnboardingHero: View {
    
    @State var appeared = false
    @State var imageAppeared = false
    
    var body: some View {
        GeometryReader { geometry in
            if appeared {
                VStack(alignment: .leading) {
                    Text("Smart\nBoiler")
                        .font(.system(size: 45))
                        .fontWeight(.bold)
                    
                    (Text("K") + Text("i").foregroundStyle(.white) + Text("LL"))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.accent)
                        .font(.system(size: 125))
                        .frame(height: 85)
                        .lineLimit(1)
                        .fontWeight(.black)
                    
                    NavigationLink(destination: PermissionsView()) {
                        HStack {
                            Text("Setup")
                                .font(.largeTitle.bold())
                            Image(.flame)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 25)
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .background(.accent)
                        .clipShape(.rect(cornerRadius: 16))
                        .padding(.vertical, 25)
                    }
                    
                    if imageAppeared {
                        Image(.boilerHero)
                            .resizable()
                            .scaledToFill()
                            .offset(x: 15)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
            }
        }
        .mainBackgroundGradient()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.bouncy) {
                    appeared = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.bouncy) {
                            imageAppeared = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
