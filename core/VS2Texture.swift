//
//  VS2Texture.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/12/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Metal
import CoreImage

class VS2Texture: CustomDebugStringConvertible {
    let name:String
    let debugDescription:String
    
    init(name:String) {
        self.name = name
        self.debugDescription = "Texture:\(name)"
    }
}

extension VS2Texture: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2CIImageStack) {
        stack.push(name: name)
    }
}

