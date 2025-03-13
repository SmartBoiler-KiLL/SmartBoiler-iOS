//
//  PermissionSection.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 2/25/25.
//

import SwiftUI

struct PermissionSection: View {
    
    let title: String
    let description: String
    let systemImage: String
    let permission: Bool
    let askPermission: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .frame(width: 35)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title)
                    .fontWeight(.black)
                Text(description)
            }
            
            Spacer()
            
            Button(action: askPermission) {
                Image(systemName: permission ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.largeTitle)
                    .animation(.bouncy, value: permission)
            }
        }
        .padding()
        .background(.white)
        .clipShape(.rect(cornerRadius: 16))
        .foregroundStyle(.black)
        .padding(5)
    }
}

#Preview {
    Group {
        PermissionSection(title: "Local Network", description: "Interact with KiLL at home.", systemImage: "network", permission: false, askPermission: {})
        PermissionSection(title: "Location", description: "Save where KiLL is located.", systemImage: "mappin", permission: false, askPermission: {})
    }
}
