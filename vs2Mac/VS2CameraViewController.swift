//
//  VS2CameraViewController.swift
//  vs2Mac
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI
import MetalKit

final class VS2CameraViewController: NSViewController {
    let cameraSession = VS2CameraSession()
    
    override func loadView() {
        let metalView = MTKView()
        metalView.device = self.cameraSession.gpu
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(1, 1, 1, 1)
        metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        metalView.framebufferOnly = false
        self.view = metalView
    }
    
    override func viewDidLoad() {
        cameraSession.startRunning()
    }
}

extension VS2CameraViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        cameraSession.draw(drawable: view.currentDrawable)
    }
}

extension VS2CameraViewController : NSViewControllerRepresentable {
    func makeNSViewController(context: NSViewControllerRepresentableContext<VS2CameraViewController>) -> VS2CameraViewController {
        return VS2CameraViewController()
    }
    
    func updateNSViewController(_ nsViewController: VS2CameraViewController, context: NSViewControllerRepresentableContext<VS2CameraViewController>) {
    }
}
