//
//  VS2ChromaKey.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/9/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import CoreImage

class VS2ChromaKey: CIFilter {
    private let kernel: CIKernel

    var inputImage: CIImage?
    var inputHueMin = Float(100.0)
    var inputHueMax = Float(144.0)
    var inputMinMax = Float(0.3)

    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernel = try! CIKernel(functionName: "chromaKey", fromMetalLibraryData: data)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var outputImage: CIImage? {
        get {
            guard let inputImage = inputImage else {return nil}
            //return kernel.apply(extent: inputImage.extent, arguments: [inputImage, Float(0.2)])
            return kernel.apply(extent: inputImage.extent, roiCallback: { i, r in r }, arguments:[inputImage, inputHueMin, inputHueMax, inputMinMax])
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            inputImage = value as? CIImage
        case "inputHueMin":
            inputHueMin = value as? Float ?? 100.0
        case "inputHueMax":
            inputHueMax = value as? Float ?? 140.0
        case "inputMinMax":
            inputMinMax = value as? Float ?? 0.3
        default:
            break
        }
    }
}
