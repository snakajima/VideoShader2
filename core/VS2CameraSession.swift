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
    private let pipeline = VS2Pipeline()

    private var ciContext:CIContext?
    private var commandQueue:MTLCommandQueue?
    private var ciImage:CIImage?
    private let filterScale = CIFilter(name: "CILanczosScaleTransform")
    
    // animation
    private let layer = CAShapeLayer()
    private var shapePixelBuffer:CVPixelBuffer?

    func startRunning() {
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

        // random shape layer
        layer.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat(dimension.width), height: CGFloat(dimension.height)))
        let path = CGMutablePath()
        path.move(to: CGPoint(x:0, y:0))
        path.addLine(to: CGPoint(x: 100, y: 100))
        path.addLine(to: CGPoint(x: 0, y: 100))
        path.closeSubpath()
        layer.path = path
        layer.strokeColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        layer.fillColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        // device contexts
        let width = Int(dimension.width)
        let height = Int(dimension.height)
        let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        var pixelBuffer:CVPixelBuffer? = nil
        let state = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
        if state == kCVReturnSuccess {
            shapePixelBuffer = pixelBuffer
            print("### success")
        }
        
        session.startRunning()
    }
    
    func update(script:[String:Any]) {
        pipeline.compile(script, gpu:gpu)
    }
    
    func draw(drawable:CAMetalDrawable?) {
        guard let ciContext = self.ciContext,
           let ciImage = self.ciImage,
           let commandQueue = self.commandQueue,
           let drawable = drawable,
           let filterScale = filterScale,
           let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        var ciImageShape:CIImage? = nil
        if let shapePixelBuffer = self.shapePixelBuffer {
            CVPixelBufferLockBaseAddress(shapePixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let baseAddress = CVPixelBufferGetBaseAddress(shapePixelBuffer)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            if let context = CGContext(data: baseAddress, width: Int(dimension.width), height: Int(dimension.height), bitsPerComponent: 8, bytesPerRow: Int(dimension.width * 4), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                context.clear(CGRect(origin: .zero, size: CGSize(width: Int(dimension.width), height: Int(dimension.height))))
                layer.render(in: context)
            }
            CVPixelBufferUnlockBaseAddress(shapePixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            ciImageShape = CIImage(cvImageBuffer: shapePixelBuffer)
        }
        
        let scale = CGSize(width: CGFloat(drawable.texture.width) / CGFloat(dimension.width), height: CGFloat(drawable.texture.height) / CGFloat(dimension.height))
        let scaleMin = min(scale.width, scale.height)
        filterScale.setValue(scaleMin, forKey: kCIInputScaleKey)
        filterScale.setValue(ciImage, forKey: kCIInputImageKey)
        pipeline.encode(commandBuffer: commandBuffer, ciImageSrc: filterScale.outputImage!)
        
        if let ciImageShape = ciImageShape {
            if let filter = CIFilter(name: "CIAdditionCompositing") {
                filter.setValue(ciImageShape, forKey: kCIInputBackgroundImageKey)
                filter.setValue(pipeline.pop(), forKey: kCIInputImageKey)
                pipeline.push(filter.outputImage)
            }
        }
        
        ciContext.render(pipeline.pop(), to: drawable.texture, commandBuffer: commandBuffer,
                         bounds: CGRect(origin: .zero, size: CGSize(width: drawable.texture.width, height: drawable.texture.height)),
                         colorSpace: CGColorSpaceCreateDeviceRGB())

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


