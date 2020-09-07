//
//  VS2GaussianFilter.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import MetalPerformanceShaders
import CoreImage

class VS2UnaryShader: CustomDebugStringConvertible {
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
        return VS2UnaryShader(filter:filter,
                               description:"\(name)")
    }
}

extension VS2UnaryShader: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2CIImageStack) {
        if let filter = self.filter {
            filter.setValue(stack.pop(), forKey: kCIInputImageKey)
            stack.push(filter.outputImage)
        }
    }
}
