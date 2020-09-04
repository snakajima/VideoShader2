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

    override func loadView() {
        let metalView = MTKView()
        metalView.device = self.cameraSession.gpu
        metalView.delegate = self
        metalView.clearColor = MTLClearColorMake(1, 1, 1, 1)
        metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        metalView.framebufferOnly = false
        self.view = metalView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
            print("orientation=", orientation.rawValue)
            switch(orientation) {
            case .landscapeLeft: cameraSession.orientation = AVCaptureVideoOrientation.landscapeLeft
            case .landscapeRight: cameraSession.orientation = AVCaptureVideoOrientation.landscapeRight
            case .portrait: cameraSession.orientation = AVCaptureVideoOrientation.portrait
            case .portraitUpsideDown: cameraSession.orientation = AVCaptureVideoOrientation.portraitUpsideDown
            default: break
            }
        }
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

extension VS2CameraViewController : UIViewControllerRepresentable {
    typealias UIViewControllerType = VS2CameraViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<VS2CameraViewController>) -> VS2CameraViewController {
        return VS2CameraViewController()
    }
    
    public func updateUIViewController(_ uiViewController: VS2CameraViewController, context: UIViewControllerRepresentableContext<VS2CameraViewController>) {
    }
}
