//
//  VS2Script.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Metal

class VS2Script {
    static let templates:[String:VS2Operator] = [
        "gaussianBlur": VS2GaussianBlur()
    ]
    let script:[String:Any]
    let gpu:MTLDevice
    let descriptor:MTLTextureDescriptor
    var operators = [VS2Operator]()
    var textureSrc:MTLTexture?
    var stack = [MTLTexture]()
    var pool = [MTLTexture]()

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
        operators.removeAll()
        for element in pipeline {
            if let key = element["filter"] as? String {
                print("key=", key)
                if let template = Self.templates[key] {
                    operators.append(template.makeFilter(gpu:gpu, props: element["props"]))
                }
            }
        }
        print("operators", operators)
    }
    
    func encode(commandBuffer:MTLCommandBuffer, textureSrc:MTLTexture) {
        self.textureSrc = textureSrc
        for item in operators {
            item.encode(to: commandBuffer, stack: self)
        }
    }
}

extension VS2Script: VS2TextureStack {
    func pop() -> MTLTexture? {
        guard let texture = stack.popLast() else {
            return textureSrc
        }
        // LATER: push it to pool for reuse
        return texture
    }
    
    func push() -> MTLTexture? {
        // LATER: pop from pool for reuse
        guard let texture = gpu.makeTexture(descriptor: descriptor) else {
            return nil
        }
        stack.append(texture)
        return texture
    }
}
