//
//  VS2Blender.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/7/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Metal
import CoreImage

class VS2Blender: VS2ShaderBase {
    static let filters:[String:[String:Any]] = [
        "additionCompositing": [
            "name":"CIAdditionCompositing",
        ],
        "darkenBlendMode": [
            "name":"CIDarkenBlendMode",
        ],
        "differenceBlendMode": [
            "name":"CIDifferenceBlendMode",
        ],
    ]
    
    static func makeShader(name:String, props: [String:Any], gpu:MTLDevice) -> VS2Shader? {
        return VS2ShaderBase.makeShader(filters:Self.filters, name:name, props:props, gpu:gpu)
    }
}

extension VS2Blender: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2CIImageStack) {
        if let filter = self.filter {
            filter.setValue(stack.pop(), forKey: kCIInputImageKey)
            filter.setValue(stack.pop(), forKey: kCIInputBackgroundImageKey)
            stack.push(filter.outputImage)
        }
    }
}
