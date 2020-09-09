//
//  VS2Mosaic.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/8/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import CoreImage

class VS2Mosaic: CIFilter {
    private let kernel: CIKernel

    var inputImage: CIImage?
    var inputColor = CIColor.white

    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernel = try! CIKernel(functionName: "mosaic", fromMetalLibraryData: data)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var outputImage: CIImage? {
        get {
            guard let inputImage = inputImage else {return nil}
            //return kernel.apply(extent: inputImage.extent, arguments: [inputImage, Float(0.2)])
            return kernel.apply(extent: inputImage.extent, roiCallback: { i, r in r }, arguments:[inputImage, CIVector(x: inputColor.red, y: inputColor.green, z: inputColor.blue)])
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            inputImage = value as? CIImage
        case "inputColor":
            inputColor = value as? CIColor ?? CIColor.white
        default:
            break
        }
    }
}
