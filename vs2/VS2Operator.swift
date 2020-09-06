//
//  VS2Filter.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Metal

public protocol VS2Operator {
    func makeFilter(props:Any?) -> VS2Operator
    func encode(stack:VS2TextureStack, gpu:MTLDevice, commandBuffer:MTLCommandBuffer)
}

public protocol VS2TextureStack {
    func pop() -> MTLTexture?
    func push() -> MTLTexture?
}

