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

class VS2Filter {
    var filter:CIFilter?
    var debugDescription:String
    
    init(filter:CIFilter?, description:String) {
        self.filter = filter
        self.debugDescription = description
    }

    private static let filters:[String:[String:Any]] = [
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
        return VS2Filter(filter:filter,
                               description:"\(name)")
    }
}

extension VS2Filter: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2CIImageStack) {
        if let filter = self.filter {
            filter.setValue(stack.pop(), forKey: kCIInputImageKey)
            stack.push(filter.outputImage)
        }
    }
}
