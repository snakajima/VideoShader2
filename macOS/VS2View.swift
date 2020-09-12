//
//  VS2View.swift
//  vs2Mac
//
//  Created by SATOSHI NAKAJIMA on 9/8/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import SwiftUI
import MetalKit

struct VS2View: NSViewRepresentable {
    @Binding var script:[String:Any]
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeNSView(context: NSViewRepresentableContext<VS2View>) -> MTKView {
        let metalView = MTKView()
        metalView.device = context.coordinator.cameraSession.gpu
        metalView.delegate = context.coordinator
        metalView.clearColor = MTLClearColorMake(1, 1, 1, 1)
        metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.autoResizeDrawable = true
        metalView.framebufferOnly = false // without this, window is not resizable
        return metalView
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<VS2View>) {
        context.coordinator.cameraSession.update(script:script)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        let gpu:MTLDevice
        let cameraSession:VS2CameraSession
        let view: VS2View
        
        private let layer = CALayer()
        private let shapeLayer = CAShapeLayer()
        private let textLayer = CATextLayer()
        private let renderer:CARenderer
        private let texture:MTLTexture

        init(_ view: VS2View) {
            self.view = view
            gpu = MTLCreateSystemDefaultDevice()!
            cameraSession = VS2CameraSession(gpu:gpu)
            cameraSession.startRunning()

            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 600, height: 400, mipmapped: false)
            textureDescriptor.usage = [MTLTextureUsage.shaderRead, .shaderWrite, .renderTarget]
            texture = gpu.makeTexture(descriptor: textureDescriptor)!
            renderer = CARenderer(mtlTexture: texture, options: nil)
            layer.addSublayer(shapeLayer)
            layer.addSublayer(textLayer)
            renderer.layer = layer
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer.bounds = CGRect(origin: .zero, size: size)

            textLayer.frame = CGRect(origin: .zero, size: size)
            textLayer.position = CGPoint(x: 300, y: 50)
            textLayer.string = "Hello World"
            textLayer.fontSize = 32
            textLayer.foregroundColor = NSColor.green.cgColor
            
            shapeLayer.frame = CGRect(origin: .zero, size: size)
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
            shapeLayer.strokeColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
            shapeLayer.fillColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.toValue = rectanglePath
            pathAnimation.duration = 0.75
            pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            pathAnimation.autoreverses = true
            pathAnimation.repeatCount = .greatestFiniteMagnitude
            shapeLayer.add(pathAnimation, forKey: "pathAnimation")
        }
        
        func draw(in view: MTKView) {
            renderer.beginFrame(atTime: CACurrentMediaTime(), timeStamp: nil)
            renderer.addUpdate(renderer.bounds)
            renderer.render()
            renderer.endFrame()
            
            cameraSession.draw(drawable: view.currentDrawable, texture:texture)
        }
        
    }
}
