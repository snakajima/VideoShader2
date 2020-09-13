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

class VS2Blender: CustomDebugStringConvertible {
    var filter:CIFilter?
    var debugDescription:String
    var isMask = false
    
    init(filter:CIFilter?, description:String) {
        self.filter = filter
        self.debugDescription = description
    }

    static let filters:[String:[String:Any]] = [
        "maskedVariableBlur": [
            "name":"CIMaskedVariableBlur",
            "props":[
                "radius": kCIInputRadiusKey
            ],
            "isMask":true
        ],
        "addition": [
            "name":"CIAdditionCompositing",
        ],
        "colorBlend": [
            "name":"CIColorBlendMode",
        ],
        "colorBurnBlend": [
            "name":"CIColorBurnBlendMode",
        ],
        "colorDodgeBlend": [
            "name":"CIColorDodgeBlendMode",
        ],
        "darkenBlend": [
            "name":"CIDarkenBlendMode",
        ],
        "differenceBlend": [
            "name":"CIDifferenceBlendMode",
        ],
        "divideBlend": [
            "name":"CIDivideBlendMode",
        ],
        "exclusionBlend": [
            "name":"CIExclusionBlendMode",
        ],
        "hardLightBlend": [
            "name":"CIHardLightBlendMode",
        ],
        "hueBlend": [
            "name":"CIHueBlendMode",
        ],
        "lightenBlend": [
            "name":"CILightenBlendMode",
        ],
        "linearBurnBlend": [
            "name":"CILinearBurnBlendMode",
        ],
        "linearDodgeBlend": [
            "name":"CILinearDodgeBlendMode",
        ],
        "luminosityDodgeBlend": [
            "name":"CILuminosityDodgeBlendMode",
        ],
        "maximum": [
            "name":"CIMaximumCompositing",
        ],
        "minimum": [
            "name":"CIMinimumCompositing",
        ],
        "sourceOver": [
            "name":"CISourceOverCompositing",
        ],
    ]
    
    static func makeShader(name:String, props: [String:Any], gpu:MTLDevice) -> VS2Shader? {
        guard let filterInfo = Self.filters[name] else {
            print("no filter", name)
            return nil
        }
        let filter = VS2Filter.makeCIFilter(filterInfo:filterInfo, props:props)
        let shader = VS2Blender(filter:filter, description:"\(name)")
        if let isMask = filterInfo["isMask"] as? Bool, isMask {
            shader.isMask = true
            print("isMask", name)
        }
        return shader
    }
}

extension VS2Blender: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2CIImageStack) {
        if let filter = self.filter {
            if isMask {
                filter.setValue(stack.pop(), forKey: "inputMask") // BUG in OS: kCIInputMaskImageKey is wrong
                filter.setValue(stack.pop(), forKey: kCIInputImageKey)
            } else {
                filter.setValue(stack.pop(), forKey: kCIInputImageKey)
                filter.setValue(stack.pop(), forKey: kCIInputBackgroundImageKey)
            }
            stack.push(filter.outputImage)
        }
    }
}
