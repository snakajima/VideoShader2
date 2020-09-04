//
//  VS2CameraSession.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import AVFoundation
import MetalPerformanceShaders

class VS2CameraSession: NSObject {
    let gpu = MTLCreateSystemDefaultDevice()!

    private let session = AVCaptureSession()
    private let camera = AVCaptureDevice.default(for: .video)
    private var textureCache:CVMetalTextureCache?
    private var texture:MTLTexture?

    func startCapturing() {
        CVMetalTextureCacheCreate(nil, nil, gpu, nil, &textureCache)
        guard let camera = camera,
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        guard session.canAddInput(input) else {
            return
        }
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA ]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)

        session.startRunning()
    }
    
    func draw(drawable:CAMetalDrawable?) {
        guard let texture = self.texture,
           let drawable = drawable,
           let commandQueue = gpu.makeCommandQueue(),
           let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        // Apply filter(s)
        let filter = MPSImageGaussianBlur(device:gpu, sigma: 10.0)
        filter.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: drawable.texture)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        self.texture = nil // no need to draw it again
    }
}

extension VS2CameraSession : AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
           let textureCache = self.textureCache {
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            var textureRef:CVMetalTexture?
            CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer, nil,
                                                      .bgra8Unorm, width, height, 0, &textureRef)
            texture = CVMetalTextureGetTexture(textureRef!)
        }
    }
}


