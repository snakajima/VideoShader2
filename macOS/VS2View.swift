//
//  VS2View.swift
//  vs2Mac
//
//  Created by SATOSHI NAKAJIMA on 9/8/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import SwiftUI
import MetalKit

struct VS2View: NSViewRepresentable {
    @Binding var script:[String:Any]
    var layer:CALayer?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeNSView(context: NSViewRepresentableContext<VS2View>) -> MTKView {
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
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<VS2View>) {
        /*
        */
        context.coordinator.update(script:script, layer:layer)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        let gpu:MTLDevice
        let cameraSession:VS2CameraSession
        let view: VS2View
        
        private let renderer:CARenderer
        private let texture:MTLTexture

        init(_ view: VS2View) {
            self.view = view
            gpu = MTLCreateSystemDefaultDevice()!
            cameraSession = VS2CameraSession(gpu:gpu)
            cameraSession.startRunning()

            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 600, height: 400, mipmapped: false)
            textureDescriptor.usage = [MTLTextureUsage.shaderRead, .shaderWrite, .renderTarget]
            texture = gpu.makeTexture(descriptor: textureDescriptor)!
            renderer = CARenderer(mtlTexture: texture, options: nil)
            /*
            layer.shadowRadius = 10.0
            layer.shadowColor = NSColor.black.cgColor
            layer.shadowOffset = CGSize(width: 3.0, height: -3.0)
            layer.shadowOpacity = 1.0
            */
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer.bounds = CGRect(origin: .zero, size: size)
            
            if let layer = renderer.layer {
                let scale = size.height / 640.0
                layer.anchorPoint = CGPoint(x: 0.0, y: 0)
                layer.position = CGPoint(x: 0, y: 0)
                layer.transform = CATransform3DMakeScale(scale, scale, 1.0)
            }
        }
        
        func update(script:[String:Any], layer:CALayer?) {
            cameraSession.update(script:script)
            renderer.layer = layer
        }
        
        func draw(in view: MTKView) {
            if cameraSession.isProcessing {
                print("processing")
                return
            }
            renderer.beginFrame(atTime: CACurrentMediaTime(), timeStamp: nil)
            renderer.addUpdate(renderer.bounds)
            renderer.render()
            renderer.endFrame()
            
            cameraSession.draw(drawable: view.currentDrawable, textures:["star":texture])
        }
        
    }
}


struct VS2View_Previews: PreviewProvider {
    static var previews: some View {
        Foo()
    }
}

private let s_script0 = [
    "pipeline": [[
        "texture": "star"
    ],[
        "blender": "sourceOver"
    ]]
]

private struct Foo: View {
@State var script0:[String:Any] = s_script0
let layer:CALayer = { ()-> CALayer in
        let textLayer = CATextLayer()

        textLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 200, height: 50))
        textLayer.position = CGPoint(x: 100, y: 100)
        textLayer.string = "Hello World"
        textLayer.fontSize = 32
        textLayer.foregroundColor = NSColor.green.cgColor
        textLayer.backgroundColor = NSColor.red.cgColor
    
        let layer = CALayer()
        layer.addSublayer(textLayer)
        return layer
}()
var body: some View {
    return VS2View(script:$script0, layer:layer)
    }
}
