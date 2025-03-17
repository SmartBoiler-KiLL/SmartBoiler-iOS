//
//  Math.swift
//  SmartBoiler-iOS
//
//  Created by Leonardo Larrañaga on 3/12/25.
//

import Foundation

func map<T: FloatingPoint>(_ value: T, from: ClosedRange<T>, to: ClosedRange<T>) -> T {
    to.lowerBound + (value - from.lowerBound) * (to.upperBound - to.lowerBound) / (from.upperBound - from.lowerBound)
}

func map(_ value: Int, from: ClosedRange<Int>, to: ClosedRange<Int>) -> Int {
    to.lowerBound + (value - from.lowerBound) * (to.upperBound - to.lowerBound) / (from.upperBound - from.lowerBound)
}

func constrain<T: FloatingPoint>(_ value: T, min minimum: T, max maximum: T) -> T {
    min(max(value, minimum), maximum)
}

func constrain(_ value: Int, min minimum: Int, max maximum: Int) -> Int {
    min(max(value, minimum), maximum)
}
