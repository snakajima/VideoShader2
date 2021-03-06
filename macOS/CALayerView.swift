//
//  Animation.swift
//  vs2Mac
//
//  Created by SATOSHI NAKAJIMA on 9/11/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import SwiftUI
import MetalKit

struct CALayerView: NSViewRepresentable {
    let layer = CALayer()
    let shapeLayer = CAShapeLayer()
    let textLayer = CATextLayer()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<CALayerView>) -> NSView {
        let view = NSView()
        view.layer = layer
        layer.addSublayer(shapeLayer)
        layer.addSublayer(textLayer)
        
        textLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        textLayer.position = CGPoint(x: 200, y: 100)
        textLayer.string = "Hello World"
        textLayer.fontSize = 32
        textLayer.foregroundColor = NSColor.green.cgColor
        return view
    }
    
    func updateNSView(_ view: NSView, context: NSViewRepresentableContext<CALayerView>) {
        let starPath = CGMutablePath()
        starPath.move(to: CGPoint(x: 81.5, y: 7.0))
        starPath.addLine(to: CGPoint(x: 101.07, y: 63.86))
        starPath.addLine(to: CGPoint(x: 163.0, y: 64.29))
        starPath.addLine(to: CGPoint(x: 113.16, y: 99.87))
        starPath.addLine(to: CGPoint(x: 131.87, y: 157.0))
        starPath.addLine(to: CGPoint(x: 81.5, y: 122.13))
        starPath.addLine(to: CGPoint(x: 31.13, y: 157.0))
        starPath.addLine(to: CGPoint(x: 49.84, y: 99.87))
        starPath.addLine(to: CGPoint(x: 0.0, y: 64.29))
        starPath.addLine(to: CGPoint(x: 61.93, y: 63.86))
        starPath.addLine(to: CGPoint(x: 81.5, y: 7.0))
        
        let rectanglePath = CGMutablePath()
        rectanglePath.move(to: CGPoint(x: 81.5, y: 7.0))
        rectanglePath.addLine(to: CGPoint(x: 163.0, y: 7.0))
        rectanglePath.addLine(to: CGPoint(x: 163.0, y: 82.0))
        rectanglePath.addLine(to: CGPoint(x: 163.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 163.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 82.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: 82.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: 7.0))
        rectanglePath.addLine(to: CGPoint(x: 81.5, y: 7.0))
        
        shapeLayer.path = starPath
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.toValue = rectanglePath
        pathAnimation.duration = 0.75
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathAnimation.autoreverses = true
        pathAnimation.repeatCount = .greatestFiniteMagnitude

        shapeLayer.add(pathAnimation, forKey: "pathAnimation")
        
        shapeLayer.strokeColor = NSColor.red.cgColor
        shapeLayer.fillColor = NSColor.green.cgColor
    }
    
    class Coordinator: NSObject {
        let view: CALayerView
        init(_ view: CALayerView) {
            self.view = view
        }
    }
}

struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text(verbatim: "foo")
            CALayerView()
            Text(verbatim: "bar")
        }
    }
}

