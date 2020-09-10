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
                "radius": "inputRadius", // DEBUGGING: kCIInputRadiusKey
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
                "noiseLevel": "inputNoiseLevel", // BUGBUG: missing KCInput..Key
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

        "colorClamp": [
            "name":"CIColorClamp",
            "props":[
                "minComponents": "inputMinComponents", // BUGBUG: missing KCInput..Key
                "maxComponents": "inputMaxComponents", // BUGBUG: missing KCInput..Key
            ]
        ],
        "colorControls": [
            "name":"CIColorControls",
            "props":[
                "saturation": kCIInputSaturationKey,
                "brightness": kCIInputBrightnessKey,
                "contrast": kCIInputContrastKey
            ]
        ],

        
        
        "edgeWork": [
            "name":"CIEdgeWork",
            "props":[
                "radius": kCIInputRadiusKey
            ]
        ],
        "gloom": [
            "name":"CIGloom",
            "props":[
                "radius": kCIInputRadiusKey,
                "intensity": kCIInputIntensityKey
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
            "props":[
                "point0": "inputPoint0",
                "point1": "inputPoint1",
                "point2": "inputPoint2",
                "point3": "inputPoint3",
                "point4": "inputPoint4",
            ]
        ],
        "edges": [
            "name":"CIEdges",
            "props":[
                "intensity": kCIInputIntensityKey
            ]
        ],
        "monochrome": [
            "name":"CIColorMonochrome",
            "props":[
                "color": kCIInputColorKey,
                "intensity": kCIInputIntensityKey
            ]
        ],

        // Filters with custom kernels
        "toone": [
            "name":"VS2TooneFilter",
            // TODO: props
        ],
        "mono": [
            "name":"VS2MonoFilter",
            "props":[
                "color": kCIInputColorKey,
            ]
        ],
        "halftone": [
            "name":"VS2HalfTone",
            "props":[
                "radius": kCIInputRadiusKey,
            ]
        ],
        "chromaKey": [
            "name":"VS2ChromaKey",
            "props":[
                "hueMin": "inputHueMin",
                "hueMax": "inputHueMax",
                "minMax": "inputMinMax",
            ]
        ],
        "boolean": [
            "name":"VS2Boolean",
            "props":[
                "range": "inputRange",
                "color1": "inputColor1",
                "color2": "inputColor2",
            ]
        ],
    ]
    
    static func asCGFloat(_ value:Any) -> CGFloat {
        if let intValue = value as? Int {
            return CGFloat(intValue)
        } else if let doubleValue = value as? Double {
            return CGFloat(doubleValue)
        }
        return 0.0
    }
    
    static func makeCIFilter(filterInfo:[String:Any], props: [String:Any]) -> CIFilter? {
        guard let ciName = filterInfo["name"] as? String else {
            return nil
        }
        var filter = CIFilter(name: ciName)
        if filter == nil {
            switch(ciName) {
            case "VS2TooneFilter":
                filter = VS2TooneFilter()
            case "VS2MonoFilter":
                filter = VS2MonoFilter()
            case "VS2HalfTone":
                filter = VS2HalfTone()
            case "VS2ChromaKey":
                filter = VS2ChromaKey()
            case "VS2Boolean":
                filter = VS2Boolean()
            default:
                print("CIFilter(): no filter with ", ciName)
            }
        }
        if let propKeys = filterInfo["props"] as? [String:Any] {
            for (key, inputKey) in propKeys {
                if let inputKey = inputKey as? String,
                   let value = props[key] {
                    print(ciName, key, inputKey, value)
                    switch(inputKey) {
                    case kCIInputCenterKey,
                         "inputPoint0", "inputPoint1", "inputPoint2", "inputPoint3", "inputPoint4", "inputRange":
                        if let array = value as? [Any], array.count == 2 {
                            filter?.setValue(CIVector(
                                x: Self.asCGFloat(array[0]),
                                y: Self.asCGFloat(array[1])), forKey: inputKey)
                        }
                    case "inputColor1", "inputColor2":
                        if let array = value as? [Any], array.count == 4 { // LATER: or 3
                            filter?.setValue(CIColor(
                                red: Self.asCGFloat(array[0]),
                                green: Self.asCGFloat(array[1]),
                                blue: Self.asCGFloat(array[2]),
                                alpha: Self.asCGFloat(array[3])), forKey: inputKey)
                        }
                    case "inputMinComponents", "inputMaxComponents":
                        if let array = value as? [Any], array.count == 4 {
                            filter?.setValue(CIVector(
                                x: Self.asCGFloat(array[0]),
                                y: Self.asCGFloat(array[1]),
                                z: Self.asCGFloat(array[2]),
                                w: Self.asCGFloat(array[3])), forKey: inputKey)
                        }
                    case kCIInputColorKey:
                        if let array = value as? [Any], array.count == 3 {
                            filter?.setValue(CIColor(
                                red: Self.asCGFloat(array[0]),
                                green: Self.asCGFloat(array[1]),
                                blue: Self.asCGFloat(array[2])), forKey: inputKey)
                        }
                    default:
                        filter?.setValue(value, forKey: inputKey)
                    }
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
