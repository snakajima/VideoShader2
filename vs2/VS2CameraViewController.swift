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
import AVFoundation

final class VS2CameraViewController: UIViewController {
    let cameraSession = VS2CameraSession()
    let metalView = MTKView()

    override func viewDidLoad() {
        cameraSession.startRunning()
        let size = CGSize(width:cameraSession.dimension.width, height:cameraSession.dimension.height)
        metalView.frame = CGRect(origin: .zero, size: size)
        metalView.device = self.cameraSession.gpu
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(1, 1, 1, 1)
        metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        metalView.framebufferOnly = false
        view.addSubview(metalView)
    }
    
    override func viewDidLayoutSubviews() {
        let scale = min(view.frame.size.width / metalView.frame.size.width, view.frame.size.height / metalView.frame.size.height)
            * UIScreen.main.scale
        print(scale)
        metalView.layer.transform = CATransform3DMakeScale(scale, scale, 1.0)
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
    }
}
