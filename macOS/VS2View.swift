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
        let cameraSession = VS2CameraSession()
        let view: VS2View
        init(_ view: VS2View) {
            self.view = view
            cameraSession.startRunning()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }
        
        func draw(in view: MTKView) {
            cameraSession.draw(drawable: view.currentDrawable)
        }
        
    }
}
