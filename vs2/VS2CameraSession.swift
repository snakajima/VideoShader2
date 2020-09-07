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
    private var script:VS2Script?
    
    private var ciContext:CIContext?
    private var ciImage:CIImage?

    func startRunning() {
        ciContext = CIContext(mtlDevice: gpu)
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

        let script = VS2Script(script:[
            "pipeline": [[
                "filter": "gaussianBlur",
                "props":[
                    "radius":2
                ]
            ],[
                "filter": "edges",
            /*
            ],[
                "filter": "sobel",
            */
            ]]
        ], gpu:gpu, descriptor: descriptor)
        script.compile()
        self.script = script

        session.startRunning()
    }
    
    func draw(drawable:CAMetalDrawable?) {
        guard let ciContext = self.ciContext,
           let ciImage = self.ciImage,
           let drawable = drawable,
           let commandQueue = gpu.makeCommandQueue(),
           let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let script = self.script else {
            print("no script")
            return
        }
        script.encode(commandBuffer: commandBuffer, ciImageSrc: ciImage)

        ciContext.render(script.pop(), to: drawable.texture, commandBuffer: commandBuffer, bounds: CGRect(origin: .zero, size: CGSize(width: dimension.width, height: dimension.height)), colorSpace: CGColorSpaceCreateDeviceRGB())
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


