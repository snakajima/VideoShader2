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
import Vision

class VS2CameraSession: NSObject {
    let gpu:MTLDevice
    var dimension = CGSize.zero

    private let videoDataOutputQueue = DispatchQueue(label: "videoDataOutputQueue")
    private let session = AVCaptureSession()
    private let camera:AVCaptureDevice
    private var sampleBuffer: CMSampleBuffer? // retainer
    private let pipeline = VS2Pipeline()

    private var ciContext:CIContext?
    private var commandQueue:MTLCommandQueue?
    private var ciImage:CIImage?
    private let filterScale = CIFilter(name: "CILanczosScaleTransform")
    var isProcessing = false
    
    // Vision
    //lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    private var detectionRequests = [VNImageBasedRequest]()

    init(gpu:MTLDevice, camera:AVCaptureDevice) {
        self.gpu = gpu
        self.camera = camera
    }

    func startRunning(detectionRequests:[VNImageBasedRequest] = []) {
        // This CIContext allows us to mix regular metal shaders along with CIFilters (in future)
        commandQueue = gpu.makeCommandQueue()
        ciContext = CIContext(mtlCommandQueue: commandQueue!, options: [
            .cacheIntermediates : false,
        ])

        guard let input = try? AVCaptureDeviceInput(device: camera) else {
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
        output.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        session.addOutput(output)
        
        self.detectionRequests = detectionRequests
        
        session.startRunning()
    }
    
    func update(script:[String:Any]) {
        pipeline.compile(script, gpu:gpu)
    }
    
    func makeTexture() -> MTLTexture{
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(dimension.width), height: Int(dimension.height), mipmapped: false)
        textureDescriptor.usage = [MTLTextureUsage.shaderRead, .shaderWrite, .renderTarget]
        return gpu.makeTexture(descriptor: textureDescriptor)!
    }
    
    func draw(drawable:CAMetalDrawable?, textures:[String:MTLTexture]) {
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
        
        let scaledImage = filterScale.outputImage!
        
        pipeline.encode(commandBuffer: commandBuffer, ciImageSrc: scaledImage, textures:textures)

        ciContext.render(pipeline.pop(), to: drawable.texture, commandBuffer: commandBuffer,
                         bounds: CGRect(origin: .zero, size: CGSize(width: drawable.texture.width, height: drawable.texture.height)),
                         colorSpace: CGColorSpaceCreateDeviceRGB())

        for (_, texture) in textures {
            let passDescriptor: MTLRenderPassDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = texture
            passDescriptor.colorAttachments[0].storeAction = .store
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0.0)
            passDescriptor.colorAttachments[0].loadAction = .clear
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
            encoder?.endEncoding()
        }

        commandBuffer.present(drawable)
        isProcessing = true;
        commandBuffer.addCompletedHandler { (_) in
            self.isProcessing = false;
        }
        commandBuffer.commit()
        
        // Vision
        let imageRequestHandler = VNImageRequestHandler(ciImage: scaledImage, orientation: .downMirrored, options: [:])
        do {
            try imageRequestHandler.perform(detectionRequests)
            // try sequenceRequestHandler.perform(detectionRequests, on: scaledImage)
        } catch {
            print("perform", error.localizedDescription)
        }

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


