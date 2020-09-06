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
}

extension VS2GaussianBlur: VS2Operator {
    func encode(stack: VS2TextureStack, gpu: MTLDevice, commandBuffer: MTLCommandBuffer) {
        print("GuassianBlur:encode", sigma)
        let blurFilter = MPSImageGaussianBlur(device:gpu, sigma: 10.0)
        if let textureSrc = stack.pop(),
            let textureDest = stack.push() {
            print("GuassianBlur:encode 2")
            blurFilter.encode(commandBuffer: commandBuffer, sourceTexture: textureSrc, destinationTexture: textureDest)
        }
    }
    
    func makeFilter(props: Any?) -> VS2Operator {
        let newInstance = VS2GaussianBlur()
        if let props = props as? [String:Any] {
            print("props", props)
            if let sigma = props["sigma"] as? Float {
                print("sigma", sigma)
                newInstance.sigma = sigma
            }
        }
        return newInstance
    }
}
