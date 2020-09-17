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
        context.coordinator.cameraSession.update(script:script)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        let gpu:MTLDevice
        let cameraSession:VS2CameraSession
        let view: VS2View
        init(_ view: VS2View) {
            gpu = MTLCreateSystemDefaultDevice()!
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
            
            let device = deviceDiscoverySession.devices.first!
            cameraSession = VS2CameraSession(gpu:gpu, camera:device)
            self.view = view
        }
        
        func startRunning() {
            cameraSession.startRunning()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }
        
        func draw(in view: MTKView) {
            cameraSession.draw(drawable: view.currentDrawable, textures:[:])
        }
        
    }
}
