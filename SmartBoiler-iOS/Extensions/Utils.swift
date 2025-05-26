//
//  Utils.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 5/24/25.
//

extension String {
    var isReallyEmpty: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
