//
//  View.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/25/25.
//

import SwiftUI

extension View {
    /// Applies a background gradient to the view.
    func mainBackgroundGradient(alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .background(LinearGradient.backgroundGradient)
    }
}
