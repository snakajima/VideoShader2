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

class VS2Pipeline {
    var shaders = [VS2Shader]()
    var ciImageSrc:CIImage?
    var stack = [CIImage]()

    func compile(_ script:[String:Any], gpu:MTLDevice) {
        shaders.removeAll()
        guard let pipeline = script["pipeline"] as? [[String:Any]] else {
            print("no or invalid pipeline")
            return
        }
        
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
    }
}

extension VS2Pipeline: VS2CIImageStack {
    func pop() -> CIImage {
        guard let ciImage = stack.popLast() else {
            return ciImageSrc!
        }
        return ciImage
    }
    
    func push(_ ciImage:CIImage?) {
        if let ciImage = ciImage {
            stack.append(ciImage)
        } else {
            print("no ciImage")
        }
    }
}
