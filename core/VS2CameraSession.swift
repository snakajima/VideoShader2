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
    let gpu:MTLDevice
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
    private var renderer:CARenderer?
    private var shapeTexture:MTLTexture?
    private var ciImageShape:CIImage?
    
    init(gpu:MTLDevice) {
        self.gpu = gpu
    }

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
        let starPath = CGMutablePath()
        starPath.move(to: CGPoint(x: 81.5, y: 7.0))
        starPath.addLine(to: CGPoint(x: 101.07, y: 63.86))
        starPath.addLine(to: CGPoint(x: 163.0, y: 64.29))
        starPath.addLine(to: CGPoint(x: 113.16, y: 99.87))
        starPath.addLine(to: CGPoint(x: 131.87, y: 157.0))
        starPath.addLine(to: CGPoint(x: 81.5, y: 122.13))
        starPath.addLine(to: CGPoint(x: 31.13, y: 157.0))
        starPath.addLine(to: CGPoint(x: 49.84, y: 99.87))
        starPath.addLine(to: CGPoint(x: 0.0, y: 64.29))
        starPath.addLine(to: CGPoint(x: 61.93, y: 63.86))
        starPath.addLine(to: CGPoint(x: 81.5, y: 7.0))
        
        let rectanglePath = CGMutablePath()
        rectanglePath.move(to: CGPoint(x: 81.5, y: 7.0))
        rectanglePath.addLine(to: CGPoint(x: 163.0, y: 7.0))
        rectanglePath.addLine(to: CGPoint(x: 163.0, y: 82.0))
        rectanglePath.addLine(to: CGPoint(x: 163.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 163.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 82.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: 157.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: 82.0))
        rectanglePath.addLine(to: CGPoint(x: 0.0, y: 7.0))
        rectanglePath.addLine(to: CGPoint(x: 81.5, y: 7.0))
        layer.path = starPath
        layer.strokeColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        layer.fillColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.toValue = rectanglePath
        pathAnimation.duration = 0.75
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathAnimation.autoreverses = true
        pathAnimation.repeatCount = .greatestFiniteMagnitude
        layer.add(pathAnimation, forKey: "pathAnimation")

        // device contexts
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 600, height: 400, mipmapped: false)
        textureDescriptor.usage = [MTLTextureUsage.shaderRead, .shaderWrite, .renderTarget]
        let texture = gpu.makeTexture(descriptor: textureDescriptor)!
        let renderer = CARenderer(mtlTexture: texture, options: nil)
        renderer.layer = self.layer
        renderer.bounds = CGRect(origin: .zero, size: CGSize(width: 600, height: 400))
        let ciImage = CIImage(mtlTexture: texture, options:nil)
        self.ciImageShape = ciImage
        self.shapeTexture = texture
        self.renderer = renderer
        session.startRunning()
    }
    
    func update(script:[String:Any]) {
        pipeline.compile(script, gpu:gpu)
    }
    
    func draw(drawable:CAMetalDrawable?, texture:MTLTexture) {
        guard let ciContext = self.ciContext,
           let ciImage = self.ciImage,
           let commandQueue = self.commandQueue,
           let drawable = drawable,
           let filterScale = filterScale,
           let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        let scale = CGSize(width: CGFloat(drawable.texture.width) / CGFloat(dimension.width), height: CGFloat(drawable.texture.height) / CGFloat(dimension.height))
        let scaleMin = min(scale.width, scale.height)
        filterScale.setValue(scaleMin, forKey: kCIInputScaleKey)
        filterScale.setValue(ciImage, forKey: kCIInputImageKey)
        pipeline.encode(commandBuffer: commandBuffer, ciImageSrc: filterScale.outputImage!)
        
        if let ciImageShape = CIImage(mtlTexture: texture, options: nil) {
            if let filter = CIFilter(name: "CISourceOverCompositing") {
                filter.setValue(ciImageShape, forKey:  kCIInputImageKey )
                filter.setValue(pipeline.pop(), forKey: kCIInputBackgroundImageKey)
                pipeline.push(filter.outputImage)
            }
        }
        
        ciContext.render(pipeline.pop(), to: drawable.texture, commandBuffer: commandBuffer,
                         bounds: CGRect(origin: .zero, size: CGSize(width: drawable.texture.width, height: drawable.texture.height)),
                         colorSpace: CGColorSpaceCreateDeviceRGB())

        let passDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = texture
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        passDescriptor.colorAttachments[0].loadAction = .clear
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        encoder?.endEncoding()

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


