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
import CoreImage

class VS2CameraSession: NSObject {
    let gpu = MTLCreateSystemDefaultDevice()!
    var dimension = CGSize.zero

    private let session = AVCaptureSession()
    private let camera = AVCaptureDevice.default(for: .video)
    private var sampleBuffer: CMSampleBuffer? // retainer
    private var pipeline:VS2Pipeline?
    
    private var ciContext:CIContext?
    private var commandQueue:MTLCommandQueue?
    private var ciImage:CIImage?

    func startRunning(script:[String:Any]) {
        // This CIContext allows us to mix regular metal shaders along with CIFilters (in future)
        commandQueue = gpu.makeCommandQueue()
        ciContext = CIContext(mtlCommandQueue: commandQueue!, options: [
            .cacheIntermediates : false,
        ])

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

        let pipeline = VS2Pipeline(script:script)
        pipeline.compile(gpu:gpu)
        self.pipeline = pipeline

        session.startRunning()
    }
    
    func draw(drawable:CAMetalDrawable?) {
        guard let ciContext = self.ciContext,
           let ciImage = self.ciImage,
           let commandQueue = self.commandQueue,
           let drawable = drawable,
           let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let pipeline = self.pipeline else {
            print("no pipeline")
            return
        }
        pipeline.encode(commandBuffer: commandBuffer, ciImageSrc: ciImage)
        
        let scale = min(Double(drawable.texture.width) / Double(dimension.width), Double(drawable.texture.height) / Double(dimension.height))
        let filterScale = CIFilter(name: "CILanczosScaleTransform", parameters: [
            kCIInputScaleKey:scale,
            kCIInputImageKey:pipeline.pop()
        ])
        pipeline.push(filterScale?.outputImage)

        ciContext.render(pipeline.pop(), to: drawable.texture, commandBuffer: commandBuffer, bounds: CGRect(origin: .zero, size: CGSize(width: dimension.width, height: dimension.height)), colorSpace: CGColorSpaceCreateDeviceRGB())

        commandBuffer.present(drawable)
        commandBuffer.commit()
        self.ciImage = nil // no need to draw it again
    }
}

extension VS2CameraSession : AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            ciImage = CIImage(cvImageBuffer: pixelBuffer)
            self.sampleBuffer = sampleBuffer // to retain the sampleBuffer behind the texture
        }
    }
}


