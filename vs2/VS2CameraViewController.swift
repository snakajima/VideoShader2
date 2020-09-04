//
//  VS2CameraViewController.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import UIKit
import SwiftUI
import MetalKit

final class VS2CameraViewController: UIViewController {
    let cameraSession = VS2CameraSession()
    //var previewLayer:AVCaptureVideoPreviewLayer?
    var metalView:MTKView?
    override func viewDidLoad() {
        cameraSession.startCapturing()
        
        /*
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(previewLayer, at: 0)
        //previewLayer.frame = view.frame
        self.previewLayer = previewLayer
        */
        
        // metal
        let metalView = MTKView(frame: view.bounds, device: self.cameraSession.gpu)
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(1, 1, 1, 1)
        metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        metalView.framebufferOnly = false
        //metalView.autoResizeDrawable = false
        view.addSubview(metalView)
        self.metalView = metalView;
    }
    
    override func viewDidLayoutSubviews() {
        //self.previewLayer?.frame = view.frame
        metalView?.frame = view.frame
    }
}

extension VS2CameraViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        cameraSession.draw(drawable: view.currentDrawable)
    }
}

extension VS2CameraViewController : UIViewControllerRepresentable {
    typealias UIViewControllerType = VS2CameraViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<VS2CameraViewController>) -> VS2CameraViewController {
        return VS2CameraViewController()
    }
    
    public func updateUIViewController(_ uiViewController: VS2CameraViewController, context: UIViewControllerRepresentableContext<VS2CameraViewController>) {
        //
    }
}
