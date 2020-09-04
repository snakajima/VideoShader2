//
//  VS2CameraViewController.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftUI

final class VS2CameraViewController: UIViewController {
    let cameraSession = VS2CameraSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    override func viewDidLoad() {
        cameraSession.startCapturing()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.frame
        self.previewLayer = previewLayer
    }
    
    override func viewDidLayoutSubviews() {
        self.previewLayer?.frame = view.frame
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
