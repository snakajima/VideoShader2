//
//  VS2CameraSession.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import AVFoundation

class VS2CameraSession: NSObject {
    let session = AVCaptureSession()
    let frontCamera = AVCaptureDevice.default(for: .video)
    let device = MTLCreateSystemDefaultDevice()!
    var textureCache:CVMetalTextureCache?
    var texture:MTLTexture?

    func startCapturing() {
        CVMetalTextureCacheCreate(nil, nil, device, nil, &textureCache)
        if let camera = frontCamera, let input = try? AVCaptureDeviceInput(device: camera) {
            session.beginConfiguration()
            if session.canAddInput(input) {
                session.addInput(input)
                print("addInput")
                setOutput()
            }
            session.commitConfiguration()
            session.startRunning()
            print("startRunning")
        }
    }
    
    private func setOutput() {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA ]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        print("setOutput")
    }
}

extension VS2CameraSession : AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
           let textureCache = self.textureCache {
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            var textureRef:CVMetalTexture?
            CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil, .bgra8Unorm, width, height, 0, &textureRef)
            texture = CVMetalTextureGetTexture(textureRef!)
        }
    }
}


