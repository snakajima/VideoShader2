//
//  VS2CameraSession.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//
// https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/Drawables.html

import AVFoundation
import MetalPerformanceShaders

class VS2CameraSession: NSObject {
    let gpu = MTLCreateSystemDefaultDevice()!
    var orientation = AVCaptureVideoOrientation.landscapeLeft
    var dimension = CGSize.zero

    private let session = AVCaptureSession()
    private let camera = AVCaptureDevice.default(for: .video)
    private var textureCache:CVMetalTextureCache?
    private var texture:MTLTexture?
    private var sampleBuffer: CMSampleBuffer? // retainer
    private var descriptor:MTLTextureDescriptor?

    func startRunning() {
        CVMetalTextureCacheCreate(nil, nil, gpu, nil, &textureCache)
        guard let camera = camera,
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        guard session.canAddInput(input) else {
            return
        }
        session.addInput(input)
        let formatDescription = camera.activeFormat.formatDescription
        let dimension = CMVideoFormatDescriptionGetDimensions(formatDescription)
        self.dimension = CGSize(width: CGFloat(dimension.width), height: CGFloat(dimension.height))
        print(self.dimension)
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Int(dimension.width), height: Int(dimension.height), mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        self.descriptor = descriptor
        
        let output = AVCaptureVideoDataOutput()
        guard session.canAddOutput(output) else {
            return
        }
        output.alwaysDiscardsLateVideoFrames = true
        #if os(macOS)
        // https://stackoverflow.com/questions/46549906/cvmetaltexturecachecreatetexturefromimage-returns-6660-on-macos-10-13
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]
        #else
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        #endif
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        
        session.startRunning()
    }
    
    func makeTexture() -> MTLTexture? {
        guard let descriptor = self.descriptor else {
            return nil
        }
        return gpu.makeTexture(descriptor: descriptor)
    }
    
    func draw(drawable:CAMetalDrawable?) {
        guard let texture = self.texture,
           let drawable = drawable,
           let commandQueue = gpu.makeCommandQueue(),
           let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        // Apply filter(s)
        guard let texture2 = makeTexture() else {
            return
        }
        let blurFilter = MPSImageGaussianBlur(device:gpu, sigma: 10.0)
        blurFilter.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: texture2)

        // Scale it to drawable
        let ratio = min(Double(drawable.texture.width) / Double(texture.width), Double(drawable.texture.height) / Double(texture.height))
        var transform = MPSScaleTransform(scaleX: ratio, scaleY: ratio, translateX: 0.0, translateY: 0.0)
        let filter = MPSImageBilinearScale(device: gpu)
        withUnsafePointer(to: &transform) { (transformPtr: UnsafePointer<MPSScaleTransform>) -> () in
            filter.scaleTransform = transformPtr
            filter.encode(commandBuffer: commandBuffer, sourceTexture: texture2, destinationTexture: drawable.texture)
        }
        //let filter = MPSImageGaussianBlur(device:gpu, sigma: 10.0)
        //filter.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: drawable.texture)

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
            self.sampleBuffer = sampleBuffer // to retain the sampleBuffer behind the texture
        }
    }
}


