//
//  VS2TooneFilter.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/8/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import CoreImage

class VS2TooneFilter: CIFilter {
    private let kernel: CIColorKernel

    var inputImage: CIImage?

    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernel = try! CIColorKernel(functionName: "toone", fromMetalLibraryData: data)
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var outputImage: CIImage? {
        get {
            guard let inputImage = inputImage else {return nil}
            return kernel.apply(extent: inputImage.extent, arguments: [inputImage])
        }
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            inputImage = value as? CIImage
        default:
            break
        }
    }
}
