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
    static let filters:[String:[String:Any]] = [
        "additionCompositing": [
            "name":"CIAdditionCOmpositing",
        ],
    ]
    var filter:CIFilter?
    var debugDescription:String
    
    init(filter:CIFilter?, description:String) {
        self.filter = filter
        self.debugDescription = description
    }
    
    static func makeShader(filterInfo:[String:Any], props: [String:Any], gpu:MTLDevice) -> VS2Shader? {
        guard let name = filterInfo["name"] as? String else {
            return nil
        }
        let filter = CIFilter(name: name)
        if let propKeys = filterInfo["props"] as? [String:Any] {
            for (key, inputKey) in propKeys {
                if let inputKey = inputKey as? String,
                   let value = props[key] {
                    print(name, key, value)
                    filter?.setValue(value, forKey: inputKey)
                }
            }
        }
        return VS2Filter(filter:filter,
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
