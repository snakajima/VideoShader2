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
    var shader:MPSUnaryImageKernel
    init(shader:MPSUnaryImageKernel) {
        self.shader = shader
    }

    static func makeGaussianBlur(props: Any?, gpu:MTLDevice) -> VS2Shader {
        var sigma:Float = 1.0
        if let props = props as? [String:Any] {
            if let value = props["sigma"] as? Double {
                sigma = Float(value)
            }
        }
        let shader = MPSImageGaussianBlur(device:gpu, sigma: sigma)
        return VS2GaussianBlur(shader:shader)
    }
}

extension VS2GaussianBlur: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2TextureStack) {
        if let textureSrc = stack.pop(),
           let textureDest = stack.push() {
            shader.encode(commandBuffer: commandBuffer, sourceTexture: textureSrc, destinationTexture: textureDest)
        }
    }
}

extension VS2GaussianBlur: CustomDebugStringConvertible {
    var debugDescription: String {
        return "GaussianBlur:\(sigma)"
    }
}
