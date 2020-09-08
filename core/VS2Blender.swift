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
    
    init(filter:CIFilter?, description:String) {
        self.filter = filter
        self.debugDescription = description
    }

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
        "maximumCompositing": [
            "name":"CIMaximumCompositing",
        ],
    ]
    
    static func makeShader(name:String, props: [String:Any], gpu:MTLDevice) -> VS2Shader? {
        guard let filterInfo = Self.filters[name] else {
            print("no filter", name)
            return nil
        }
        let filter = VS2Filter.makeCIFilter(filterInfo:filterInfo, props:props)
        return VS2Blender(filter:filter, description:"\(name)")
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