//
//  VS2Filter.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Metal
import CoreImage

public protocol VS2Shader {
    func encode(to commandBuffer:MTLCommandBuffer, stack:VS2CIImageStack)
}

public protocol VS2CIImageStack {
    func pop() -> CIImage
    func push(_ ciImage:CIImage?)
    func push(name:String)
}

