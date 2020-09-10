//
//  VS2Boolean.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/10/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import CoreImage

class VS2Boolean: CIFilter {
    private let kernel: CIKernel

    var inputImage: CIImage?
    var inputRange = CIVector(x: 0.0, y: 0.5)
    var inputColor1 = CIColor.white
    var inputColor2 = CIColor.black

    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernel = try! CIKernel(functionName: "boolean", fromMetalLibraryData: data)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var outputImage: CIImage? {
        get {
            guard let inputImage = inputImage else {return nil}
            //return kernel.apply(extent: inputImage.extent, arguments: [inputImage, Float(0.2)])
            return kernel.apply(extent: inputImage.extent, roiCallback: { i, r in r },
                                arguments:[
                                    inputImage,
                                    inputRange,
                                    inputColor1, inputColor2
            ])
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            inputImage = value as? CIImage
        case "inputRange":
            inputRange = value as? CIVector ?? CIVector(x:0.0, y:0.5)
        case "inputColor1":
            inputColor1 = value as? CIColor ?? CIColor.white
        case "inputColor2":
            inputColor2 = value as? CIColor ?? CIColor.black
        default:
            break
        }
    }
}
