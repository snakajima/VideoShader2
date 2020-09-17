//
//  VS2View.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/8/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import SwiftUI
import MetalKit
import AVFoundation
import Vision

struct VS2View: UIViewRepresentable {
    @Binding var script:[String:Any]
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        coordinator.startRunning()
        return coordinator
   }

    func makeUIView(context: UIViewRepresentableContext<VS2View>) -> MTKView {
        let metalView = MTKView()
        metalView.device = context.coordinator.cameraSession.gpu
        metalView.delegate = context.coordinator
        metalView.clearColor = MTLClearColorMake(1, 1, 1, 1)
        metalView.colorPixelFormat = MTLPixelFormat.bgra8Unorm
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.autoResizeDrawable = true
        metalView.framebufferOnly = false // without this, window is not resizable
        return metalView
    }
    
    func updateUIView(_ UIView: MTKView, context: UIViewRepresentableContext<VS2View>) {
        context.coordinator.update(script:script, UIView:UIView)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        let gpu:MTLDevice
        let cameraSession:VS2CameraSession
        let view: VS2View
        let layer = CALayer()
        var drawableSize = CGSize.zero
        var lastFrame:CGRect? = nil
        
        init(_ view: VS2View) {
            gpu = MTLCreateSystemDefaultDevice()!
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
            
            let device = deviceDiscoverySession.devices.first!
            cameraSession = VS2CameraSession(gpu:gpu, camera:device)
            self.view = view
        }
        
        func startRunning() {
            cameraSession.startRunning(detectionRequests: prepareVisionRequest())
        }

        func prepareVisionRequest() -> [VNImageBasedRequest] {
            //var requests = [VNTrackObjectRequest]()
            let faceDetectionRequest = VNDetectHumanHandPoseRequest { (request, error) in
                if error != nil {
                    print("Detection error: \(String(describing: error)).")
                }
                guard let result = request.results?.first as? VNHumanHandPoseObservation,
                      var analyzer = try? HandGectureAnalyzer(observation: result)
                      else {
                    DispatchQueue.main.async {
                        self.lastFrame = nil
                        for sublayer in self.layer.sublayers ?? [] {
                            sublayer.removeFromSuperlayer()
                        }
                    }
                    return
                }
                
                // Low-pass filter.
                var frame = analyzer.bounds
                if let lastFrame = self.lastFrame {
                    frame = lastFrame.mixed(frame, ratio:0.2)
                }
                self.lastFrame = frame

                let vectorThumb = analyzer.vector(from: .thumbCMC, to: .thumbTip)
                let vectorIndex = analyzer.vector(from: .indexMCP, to: .indexTip)
                let vectorMid = analyzer.vector(from: .middleMCP, to: .middleTip)
                let vectorRing = analyzer.vector(from: .ringMCP, to: .ringTip)
                let vectorLittle = analyzer.vector(from: .littleMCP, to: .littleTip)

                let upThumb = -vectorThumb.dy > frame.height * 0.3
                let upThumbLarge = -vectorThumb.dy > frame.height * 0.6
                let downThumb = vectorThumb.dy > frame.height * 0.4
                let upIndex = -vectorIndex.dy > frame.height * 0.3
                let upMid = -vectorMid.dy > frame.height * 0.3
                let upRing = -vectorRing.dy > frame.height * 0.3
                let upLittle = -vectorLittle.dy > frame.height * 0.3

                var emoji = ""
                if upIndex && !upMid && !upRing && !upLittle {
                    emoji = "☝️"
                } else if upIndex && upMid && !upRing && !upLittle {
                    emoji = "✌️"
                } else if !upIndex && upMid && !upRing && !upLittle {
                    emoji = "🈲"
                } else if !upIndex && !upMid && !upRing && upThumbLarge && !upLittle {
                    emoji = "👍"
                } else if !upIndex && !upMid && !upRing && downThumb && !upLittle {
                    emoji = "👎"
                } else if upIndex && upMid && upRing && upThumb && upLittle {
                    emoji = "✋"
                } else if upIndex && !upMid && !upRing && upThumb && upLittle {
                    emoji = "🤟"
                } else if upIndex && !upMid && !upRing && !upThumb && upLittle {
                    emoji = "🤘"
                }

                var newLayers = [CALayer]()
                
                let boundLayer = CALayer()
                boundLayer.frame = frame.unnormalized(size: self.drawableSize)
                //boundLayer.backgroundColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.2)
                newLayers.append(boundLayer)

                let textLayer = CATextLayer()
                let textOrigin = CGPoint(x: boundLayer.frame.origin.x - boundLayer.frame.width * 0.5,
                                         y: boundLayer.frame.origin.y - boundLayer.frame.height * 0.5)
                let fontSize = max(boundLayer.frame.height, boundLayer.frame.width) * 1.5
                textLayer.frame = CGRect(origin: textOrigin, size: CGSize(width: fontSize, height: fontSize * 1.5))
                textLayer.string = emoji
                textLayer.fontSize = fontSize
                textLayer.opacity = 0.8
                //textLayer.backgroundColor = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)
                newLayers.append(textLayer)

                if let allPoints = try? result.recognizedPoints(forGroupKey: VNRecognizedPointGroupKey.all) {
                    for (key, point) in allPoints {
                        let location = point.location
                        let textLayer = CATextLayer()
                        var string = "?"
                        switch(key.rawValue) {
                        case "VNHLKITIP", "VNHLKIDIP", "VNHLKIPIP", "VNHLKIMCP":
                            string = "I"
                        case "VNHLKMTIP", "VNHLKMDIP", "VNHLKMPIP", "VNHLKMMCP":
                            string = "M"
                        case "VNHLKRTIP", "VNHLKRDIP", "VNHLKRPIP", "VNHLKRMCP":
                            string = "R"
                        case "VNHLKPTIP", "VNHLKPDIP", "VNHLKPPIP", "VNHLKPMCP":
                            string = "L"
                        case "VNHLKTTIP", "VNHLKTIP", "VNHLKTMP", "VNHLKTCMC":
                            string = "T"
                        case "VNHLKWRI":
                            string = "W"
                        default:
                            print(key.rawValue)
                            break
                        }
                        textLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 20, height: 20))
                        textLayer.string = string
                        textLayer.fontSize = 15
                        textLayer.foregroundColor = UIColor.green.cgColor
                        textLayer.position = CGPoint(x: location.x * self.drawableSize.width, y: location.y * self.drawableSize.height)
                        //newLayers.append(textLayer)
                    }
                }

                DispatchQueue.main.async {
                    for sublayer in self.layer.sublayers ?? [] {
                        sublayer.removeFromSuperlayer()
                    }
                    for newLayer in newLayers {
                        self.layer.addSublayer(newLayer)
                    }
                }
            }
            return [faceDetectionRequest]
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            let scale = UIScreen.main.scale
            drawableSize = CGSize(width: size.width / scale, height: size.height / scale)
            print("willChange", drawableSize)
        }
        
        func update(script:[String:Any], UIView:UIView) {
            cameraSession.update(script:script)
            if UIView.layer.sublayers?.first == nil {
                UIView.layer.addSublayer(layer)
            }
        }

        func draw(in view: MTKView) {
            cameraSession.draw(drawable: view.currentDrawable, textures:[:])
        }
        
    }
}

