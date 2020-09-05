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
        metalView.device = self.cameraSession.gpu
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(1, 1, 1, 1)
        metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        metalView.framebufferOnly = false
        view.addSubview(metalView)
        
        self.viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        let scale = UIScreen.main.scale
        let size = CGSize(width:cameraSession.dimension.width, height:cameraSession.dimension.height)
        metalView.frame = CGRect(origin: .zero, size: size)
        metalView.drawableSize = size
        /*
        let ratio = min(view.frame.size.width / size.width, view.frame.size.height / size.height)
        print(ratio)
        let xfScale = CATransform3DMakeScale(ratio, ratio, 1.0)
        let xfTranslate = CATransform3DMakeTranslation(0, -size.height / 2 * (1-ratio), 0)
        metalView.layer.transform = CATransform3DConcat(xfTranslate, xfScale)
        */
        /*
        let scale = min(view.frame.size.width / metalView.frame.size.width, view.frame.size.height / metalView.frame.size.height)
        print(scale)
        metalView.layer.transform =
        */
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
