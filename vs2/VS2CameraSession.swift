//
//  VS2CameraSession.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import AVFoundation

class VS2CameraSession {
    let session = AVCaptureSession()
    let frontCamera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .front)

    func startCapturing() {
        if let camera = frontCamera, let input = try? AVCaptureDeviceInput(device: camera) {
            if session.canAddInput(input) {
                session.addInput(input)
                session.startRunning()
                print("startRunning")
            }
        }
    }
}


