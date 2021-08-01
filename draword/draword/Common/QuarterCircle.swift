//
//  MainViews.swift
//  draword
//
//  Created by Lorenzo Sonnino on 01/08/2021.
//

import SwiftUI

// Draw a quarter of a circle
struct QuarterCircle: Shape {
    public var radius: CGFloat
    public var from: Double, to: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
                    radius: radius,
                    startAngle: Angle.degrees(from),
                    endAngle: Angle.degrees(to),
                    clockwise: true)
        return path
    }
}
