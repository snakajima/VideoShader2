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
        let textLayer = CATextLayer()
        var drawableSize = CGSize.zero
        
        init(_ view: VS2View) {
            gpu = MTLCreateSystemDefaultDevice()!
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
            
            let device = deviceDiscoverySession.devices.first!
            cameraSession = VS2CameraSession(gpu:gpu, camera:device)
            self.view = view

            textLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 200, height: 50))
            textLayer.position = CGPoint(x: 100, y: 100)
            textLayer.string = "Hello World"
            textLayer.fontSize = 32
            textLayer.foregroundColor = UIColor.green.cgColor
            
        }
        
        func startRunning() {
            cameraSession.startRunning(detectionRequests: prepareVisionRequest())
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
                        self.textLayer.position = CGPoint(x: bounds.origin.x * self.drawableSize.width, y: bounds.origin.y * self.drawableSize.height)
                    }
                }
            }
            return [faceDetectionRequest]
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            drawableSize = size
        }
        
        func update(script:[String:Any], UIView:UIView) {
            cameraSession.update(script:script)
            if UIView.layer.sublayers?.first == nil {
                UIView.layer.addSublayer(textLayer)
            }
        }

        func draw(in view: MTKView) {
            cameraSession.draw(drawable: view.currentDrawable, textures:[:])
        }
        
    }
}
