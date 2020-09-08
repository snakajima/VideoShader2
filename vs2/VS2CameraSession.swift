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
    var dimension = CGSize.zero

    private let session = AVCaptureSession()
    private let camera = AVCaptureDevice.default(for: .video)
    private var sampleBuffer: CMSampleBuffer? // retainer
    private var pipeline:VS2Pipeline?
    
    private var ciContext:CIContext?
    private var commandQueue:MTLCommandQueue?
    private var ciImage:CIImage?

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

        let pipeline = VS2Pipeline(script:[
            "pipeline": [[
                "controller": "fork",
            ],[
                "filter": "hueAdjust",
                "props":[
                    "angle":3.14
                ]
            ],[
                "filter": "edges",
            ],[
                "Xfilter": "gaussianBlur",
                "props":[
                    "radius":10
                ]
            ],[
                "filter": "exposureAdjust",
                "props":[
                    "ev":5.0
                ]
            ],[
                "Xfilter": "colorInvert",
            ],[
                "blender": "maximumCompositing",
            /*
            ],[
                "filter": "sobel",
            */
            ]]
        ], gpu:gpu)
        pipeline.compile()
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
        
        guard let script = self.pipeline else {
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


