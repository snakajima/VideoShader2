//
//  VS2View.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/8/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import SwiftUI
import MetalKit
import AVFoundation
import Vision

struct VS2View: UIViewRepresentable {
    @Binding var script:[String:Any]
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.startRunning()
        return coordinator
   }

    func makeUIView(context: UIViewRepresentableContext<VS2View>) -> MTKView {
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
    
    func updateUIView(_ UIView: MTKView, context: UIViewRepresentableContext<VS2View>) {
        context.coordinator.update(script:script, UIView:UIView)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        let gpu:MTLDevice
        let cameraSession:VS2CameraSession
        let view: VS2View
        let layer = CALayer()
        var drawableSize = CGSize.zero
        
        init(_ view: VS2View) {
            gpu = MTLCreateSystemDefaultDevice()!
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
            
            let device = deviceDiscoverySession.devices.first!
            cameraSession = VS2CameraSession(gpu:gpu, camera:device)
            self.view = view
        }
        
        func startRunning() {
            cameraSession.startRunning(detectionRequests: prepareVisionRequest())
        }

        func prepareVisionRequest() -> [VNImageBasedRequest] {
            //var requests = [VNTrackObjectRequest]()
            let faceDetectionRequest = VNDetectHumanHandPoseRequest { (request, error) in
                if error != nil {
                    print("Detection error: \(String(describing: error)).")
                }
                guard let result = request.results?.first as? VNHumanHandPoseObservation else {
                    print("Detection no result")
                    return
                }
                //var newLayers = [CALayer]()
                let allPoints = try? result.recognizedPoints(forGroupKey: VNRecognizedPointGroupKey.all)
                print(allPoints)
                /*
                for keypoints in result.keypointsMultiArray() {
                    let bounds = result.boundingBox
                    //print("bounds", bounds)
                    let textLayer = CATextLayer()
                    textLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 200, height: 50))
                    textLayer.position = CGPoint(x: 100, y: 100)
                    textLayer.string = "Hello World"
                    textLayer.fontSize = 32
                    textLayer.foregroundColor = UIColor.green.cgColor
                    textLayer.position = CGPoint(x: bounds.origin.x * self.drawableSize.width, y: bounds.origin.y * self.drawableSize.height)
                    newLayers.append(textLayer)
                }
                DispatchQueue.main.async {
                    for sublayer in self.layer.sublayers ?? [] {
                        sublayer.removeFromSuperlayer()
                    }
                    for newLayer in newLayers {
                        self.layer.addSublayer(newLayer)
                    }
                }
                */
            }
            return [faceDetectionRequest]
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            drawableSize = size
        }
        
        func update(script:[String:Any], UIView:UIView) {
            cameraSession.update(script:script)
            if UIView.layer.sublayers?.first == nil {
                UIView.layer.addSublayer(layer)
            }
        }

        func draw(in view: MTKView) {
            cameraSession.draw(drawable: view.currentDrawable, textures:[:])
        }
        
    }
}
