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
import Vision

struct VS2View: NSViewRepresentable {
    @Binding var script:[String:Any]
    var layer:CALayer?

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.startRunning()
        return coordinator
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
        
        private var renderer:CARenderer! = nil
        private var texture:MTLTexture! = nil
        private var drawableSize = CGSize.zero

        init(_ view: VS2View) {
            self.view = view
            gpu = MTLCreateSystemDefaultDevice()!
            cameraSession = VS2CameraSession(gpu:gpu)
        }
        
        func startRunning() {
            cameraSession.startRunning(detectionRequests: prepareVisionRequest())
            texture = cameraSession.makeTexture()
            renderer = CARenderer(mtlTexture: texture, options: nil)
        }

        func prepareVisionRequest() -> [VNImageBasedRequest] {
            //var requests = [VNTrackObjectRequest]()
            let faceDetectionRequest = VNDetectFaceRectanglesRequest { (request, error) in
                if error != nil {
                    print("FaceDetection error: \(String(describing: error)).")
                }
                guard let results = request.results as? [VNFaceObservation] else {
                    print("FaceDetection no result")
                    return
                }
                //print("FaceDetection count=", results.count)
                for result in results {
                    let bounds = result.boundingBox
                    //print("bounds", bounds)
                    DispatchQueue.main.async {
                        if let layer = self.renderer.layer {
                            layer.position = CGPoint(x: bounds.origin.x * self.drawableSize.width, y: bounds.origin.y * self.drawableSize.height)
                        }
                    }

                }
            }
            return [faceDetectionRequest]
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer!.bounds = CGRect(origin: .zero, size: size)
            drawableSize = size
            
            if let layer = renderer!.layer {
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
        "filter": "chromaKey",
        "props":[
            "hueMin":100.0,
            "hueMax":144.0,
            "minMax":0.4,
        ]
    ],[
        "texture": "star"
    ],[
        "filter": "fourfoldTranslatedTile",
        "props":[
            "width":240.0,
            "center":[0, 0],
        ]
    ],[
        "controller": "swap"
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
    shapeLayer.lineWidth = 2.0
    shapeLayer.lineJoin = .round
    shapeLayer.strokeColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    shapeLayer.fillColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let pathAnimation = CABasicAnimation(keyPath: "path")
    pathAnimation.toValue = rectanglePath
    pathAnimation.duration = 4.0
    pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    pathAnimation.autoreverses = true
    pathAnimation.repeatCount = .greatestFiniteMagnitude
    shapeLayer.add(pathAnimation, forKey: "pathAnimation")
    
    let layer = CALayer()
    layer.addSublayer(shapeLayer)
    layer.addSublayer(textLayer)
    layer.shadowColor = NSColor.black.cgColor
    layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    layer.shadowRadius = 3.0
    layer.shadowOpacity = 0.5

    return layer
}()
var body: some View {
    return VS2View(script:$script0, layer:layer)
    }
}
