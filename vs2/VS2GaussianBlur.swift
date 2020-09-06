//
//  VS2GaussianFilter.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

class VS2GaussianBlur: CustomDebugStringConvertible {
    var shader:MPSUnaryImageKernel
    var debugDescription:String
    init(shader:MPSUnaryImageKernel, description:String) {
        self.shader = shader
        self.debugDescription = description
    }

    static func makeGaussianBlur(props: [String:Any], gpu:MTLDevice) -> VS2Shader {
        let sigma = props["sigma"] as? Double ?? 1.0
        return VS2GaussianBlur(shader:MPSImageGaussianBlur(device:gpu, sigma: Float(sigma)),
                               description:"GaussianBlur:\(sigma)")
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