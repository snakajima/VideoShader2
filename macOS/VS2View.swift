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
    var layer:CALayer?

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
        /*
        */
        context.coordinator.update(script:script, layer:layer)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        let gpu:MTLDevice
        let cameraSession:VS2CameraSession
        let view: VS2View
        
        private let renderer:CARenderer
        private let texture:MTLTexture

        init(_ view: VS2View) {
            self.view = view
            gpu = MTLCreateSystemDefaultDevice()!
            cameraSession = VS2CameraSession(gpu:gpu)
            cameraSession.startRunning()
            texture = cameraSession.makeTexture()
            renderer = CARenderer(mtlTexture: texture, options: nil)
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer.bounds = CGRect(origin: .zero, size: size)
            
            if let layer = renderer.layer {
                let scale = size.height / 640.0
                layer.anchorPoint = CGPoint(x: 0.0, y: 0)
                layer.position = CGPoint(x: 0, y: 0)
                layer.transform = CATransform3DMakeScale(scale, scale, 1.0)
            }
        }
        
        func update(script:[String:Any], layer:CALayer?) {
            cameraSession.update(script:script)
            renderer.layer = layer
        }
        
        func draw(in view: MTKView) {
            if cameraSession.isProcessing {
                print("processing")
                return
            }
            renderer.beginFrame(atTime: CACurrentMediaTime(), timeStamp: nil)
            renderer.addUpdate(renderer.bounds)
            renderer.render()
            renderer.endFrame()
            
            cameraSession.draw(drawable: view.currentDrawable, textures:["star":texture])
        }
        
    }
}


struct VS2View_Previews: PreviewProvider {
    static var previews: some View {
        Foo()
    }
}

private let s_script0 = [
    "pipeline": [[
        "texture": "star"
    ],[
        "blender": "sourceOver"
    ]]
]

private struct Foo: View {
@State var script0:[String:Any] = s_script0
let layer:CALayer = { ()-> CALayer in
        let textLayer = CATextLayer()

        textLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 200, height: 50))
        textLayer.position = CGPoint(x: 100, y: 100)
        textLayer.string = "Hello World"
        textLayer.fontSize = 32
        textLayer.foregroundColor = NSColor.green.cgColor
        textLayer.backgroundColor = NSColor.red.cgColor
    
    let shapeLayer = CAShapeLayer()
    //shapeLayer.frame = CGRect(origin: .zero, size: size)
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
    
        let layer = CALayer()
        layer.addSublayer(textLayer)
    layer.addSublayer(shapeLayer)
        return layer
}()
var body: some View {
    return VS2View(script:$script0, layer:layer)
    }
}
