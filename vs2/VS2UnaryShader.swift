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
    var filter:CIFilter
    var debugDescription:String
    
    init(filter:CIFilter, description:String) {
        self.filter = filter
        self.debugDescription = description
    }
    
    static func makeSepiaTone(props: [String:Any], gpu:MTLDevice) -> VS2Shader {
        let intensity = props["intensity"] as? Double ?? 1.0
        let filter = CIFilter(name: "CISepiaTone")!
        //filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        return VS2UnaryShader(filter:filter,
                               description:"SepiaTone:\(intensity)")

    }
}

extension VS2UnaryShader: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2TextureStack) {
        filter.setValue(stack.pop(), forKey: kCIInputImageKey)
        stack.push(filter.outputImage)
    }
}
