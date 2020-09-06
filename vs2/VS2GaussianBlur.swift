//
//  VS2GaussianFilter.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

class VS2GaussianBlur {
    var sigma:Float = 1.0
    var shader:MPSImageGaussianBlur?
}

extension VS2GaussianBlur: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2TextureStack) {
        if let shader = self.shader,
            let textureSrc = stack.pop(),
            let textureDest = stack.push() {
            shader.encode(commandBuffer: commandBuffer, sourceTexture: textureSrc, destinationTexture: textureDest)
        }
    }
    
    func makeFilter(gpu:MTLDevice, props: Any?) -> VS2Shader {
        let newInstance = VS2GaussianBlur()
        if let props = props as? [String:Any] {
            if let sigma = props["sigma"] as? Double {
                newInstance.sigma = Float(sigma)
            }
        }
        newInstance.shader = MPSImageGaussianBlur(device:gpu, sigma: newInstance.sigma)
        return newInstance
    }
}

extension VS2GaussianBlur: CustomDebugStringConvertible {
    var debugDescription: String {
        return "GaussianBlur:\(sigma)"
    }
}
