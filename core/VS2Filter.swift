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

class VS2Filter:CustomDebugStringConvertible {
    var filter:CIFilter?
    var debugDescription:String
    
    init(filter:CIFilter?, description:String) {
        self.filter = filter
        self.debugDescription = description
    }

    private static let filters:[String:[String:Any]] = [
        "boxBlur": [
            "name":"CIBoxBlur",
            "props":[
                "radius": kCIInputRadiusKey
            ]
        ],
        "discBlur": [
            "name":"CIDiscBlur",
            "props":[
                "radius": kCIInputRadiusKey
            ]
        ],
        "gaussianBlur": [
            "name":"CIGaussianBlur",
            "props":[
                "radius": kCIInputRadiusKey
            ]
        ],
        "medianFilter": [
            "name":"CIMedianFilter",
        ],
        
        "motionBlur": [
            "name":"CIMotionBlur",
            "props":[
                "radius": kCIInputRadiusKey,
                "angle": kCIInputAngleKey,
            ]
        ],
        "noiseReduction": [
            "name":"CINoiseReduction",
            "props":[
                "noiseLevel": "noiseLevel", // BUGBUG: missing KCInput..Key
                "angle": kCIInputSharpnessKey,
            ]
        ],
        "zoomBlur": [
            "name":"CIZoomBlur",
            "props":[
                "center": kCIInputCenterKey,
                "amount": kCIInputAmountKey,
            ]
        ],

        
        "sepiaTone": [
            "name":"CISepiaTone",
            "props":[
                "intensity": kCIInputIntensityKey
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
        "exposureAdjust": [
            "name":"CIExposureAdjust",
            "props":[
                "ev": kCIInputEVKey
            ]
        ],
        "toneCurve": [
            "name":"CIToneCurve",
            // TODO: props
        ],
        "edges": [
            "name":"CIEdges",
            "props":[
                "intensity": kCIInputIntensityKey
            ]
        ]
    ]
    
    static func makeCIFilter(filterInfo:[String:Any], props: [String:Any]) -> CIFilter? {
        guard let ciName = filterInfo["name"] as? String else {
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
                    print(ciName, key, value)
                    filter?.setValue(value, forKey: inputKey)
                }
            }
        }
        return filter
    }

    static func makeShader(name:String, props: [String:Any], gpu:MTLDevice) -> VS2Shader? {
        guard let filterInfo = Self.filters[name] else {
            print("no filter", name)
            return nil
        }
        let filter = VS2Filter.makeCIFilter(filterInfo:filterInfo, props:props)
        return VS2Filter(filter:filter, description:"\(name)")
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
