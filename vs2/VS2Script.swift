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
    static let filters:[String:[String:Any]] = [
        "sepiaTone": [
            "name":"CISepiaTone",
            "props":[
                "intensity": kCIInputIntensityKey
            ]
        ],
        "gaussianBlur": [
            "name":"CIGaussianBlur",
            "props":[
                "radius": kCIInputRadiusKey
            ]
        ],
        "hueAdjust": [
            "name":"CIHueAdjust",
            "props":[
                "angle": kCIInputAngleKey
            ]
        ],
        "colorInvert": [
            "name":"CIColorInvert",
        ],
        "edges": [
            "name":"CIEdges",
            "props":[
                "intensity": kCIInputIntensityKey
            ]
        ]
    ]
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
            if let key = shaderInfo["filter"] as? String {
                print("key=", key)
                if let filterInfo = Self.filters[key] {
                    guard let shader = VS2UnaryShader.makeShader(filterInfo:filterInfo, props:shaderInfo["props"] as? [String:Any] ?? empty, gpu:gpu) else {
                        print("makeShader returned nil")
                        continue
                    }
                    shaders.append(shader)
                }
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

extension VS2Script: VS2CIImageStack {
    func pop() -> CIImage {
        guard let ciImage = stack.popLast() else {
            return ciImageSrc!
        }
        return ciImage
    }
    
    func push(_ ciImage:CIImage?) {
        if let ciImage = ciImage {
            stack.append(ciImage)
        }
    }
}
