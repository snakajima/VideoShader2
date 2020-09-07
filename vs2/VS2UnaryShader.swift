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
        filter.setValue(1, forKey: kCIInputIntensityKey)
        return VS2UnaryShader(filter:filter,
                               description:"SepiaTone:\(intensity)")

    }
    /*

    static func makeGaussianBlur(props: [String:Any], gpu:MTLDevice) -> VS2Shader {
        let sigma = props["sigma"] as? Double ?? 1.0
        return VS2UnaryShader(shader:MPSImageGaussianBlur(device:gpu, sigma:Float(sigma)),
                               description:"gaussianBlur:\(sigma)")
    }
    static func makeSobel(props: [String:Any], gpu:MTLDevice) -> VS2Shader {
        return VS2UnaryShader(shader:MPSImageSobel(device: gpu),
                               description:"sobel")
    }
    static func makeAreaMax(props: [String:Any], gpu:MTLDevice) -> VS2Shader {
        let width = props["width"] as? Int ?? 5
        let height = props["height"] as? Int ?? 5
        return VS2UnaryShader(shader:MPSImageAreaMax(device:gpu, kernelWidth: width, kernelHeight: height),
                               description:"areaMax:\(width), \(height)")
    }
    static func makeAreaMin(props: [String:Any], gpu:MTLDevice) -> VS2Shader {
        let width = props["width"] as? Int ?? 5
        let height = props["height"] as? Int ?? 5
        return VS2UnaryShader(shader:MPSImageAreaMin(device:gpu, kernelWidth: width, kernelHeight: height),
                               description:"areaMin:\(width), \(height)")
    }
    static func makeLaplacian(props: [String:Any], gpu:MTLDevice) -> VS2Shader {
        return VS2UnaryShader(shader:MPSImageLaplacian(device: gpu),
                               description:"laplacian")
    }
 */
}

extension VS2UnaryShader: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2TextureStack) {
        filter.setValue(stack.pop(), forKey: kCIInputImageKey)
        stack.push(filter.outputImage)
    }
}
