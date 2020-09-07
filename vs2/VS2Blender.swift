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

class VS2Blender {
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
    ]
    
    static func makeShader(name:String, props: [String:Any], gpu:MTLDevice) -> VS2Shader? {
        guard let filterInfo = Self.filters[name],
            let ciName = filterInfo["name"] as? String else {
            print("no filter", name)
            return nil
        }
        let filter = CIFilter(name: ciName)
        if filter == nil {
            print("CIFilter() failed with ", ciName)
        }
        if let propKeys = filterInfo["props"] as? [String:Any] {
            for (key, inputKey) in propKeys {
                if let inputKey = inputKey as? String,
                   let value = props[key] {
                    print(name, key, value)
                    filter?.setValue(value, forKey: inputKey)
                }
            }
        }
        return VS2Blender(filter:filter,
                               description:"\(name)")
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
