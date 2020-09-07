//
//  VS2Script.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Metal
import CoreImage

class VS2Script {
    let script:[String:Any]
    let gpu:MTLDevice
    let descriptor:MTLTextureDescriptor
    var shaders = [VS2Shader]()
    var ciImageSrc:CIImage?
    var stack = [CIImage]()

    init(script:[String:Any], gpu:MTLDevice, descriptor:MTLTextureDescriptor) {
        self.script = script
        self.gpu = gpu
        self.descriptor = descriptor
    }
    
    func compile() {
        guard let pipeline = script["pipeline"] as? [[String:Any]] else {
            print("no or invalid pipeline")
            return
        }
        shaders.removeAll()
        let empty = [String:Any]()
        for shaderInfo in pipeline {
            if let name = shaderInfo["filter"] as? String {
                if let shader = VS2Filter.makeShader(name:name, props:shaderInfo["props"] as? [String:Any] ?? empty, gpu:gpu) {
                    shaders.append(shader)
                }
            } else if let name = shaderInfo["blender"] as? String {
                if let shader = VS2Blender.makeShader(name:name, props:shaderInfo["props"] as? [String:Any] ?? empty, gpu:gpu) {
                    shaders.append(shader)
                }
            } else if let name = shaderInfo["controller"] as? String {
                let controller = VS2Controller(name: name)
                shaders.append(controller)
            }
        }
        print("operators", shaders)
    }
    
    func encode(commandBuffer:MTLCommandBuffer, ciImageSrc:CIImage) {
        self.ciImageSrc = ciImageSrc
        for shader in shaders {
            shader.encode(to: commandBuffer, stack: self)
        }
        print(stack.count)
    }
}

extension VS2Script: VS2CIImageStack {
    func pop() -> CIImage {
        print("pop", stack.count)
        guard let ciImage = stack.popLast() else {
            return ciImageSrc!
        }
        return ciImage
    }
    
    func push(_ ciImage:CIImage?) {
        print("push", stack.count)
        if let ciImage = ciImage {
            stack.append(ciImage)
        } else {
            print("no ciImage")
        }
    }
}
