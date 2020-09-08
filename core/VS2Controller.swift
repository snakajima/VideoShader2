//
//  VS2Controller.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/7/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Metal

class VS2Controller {
    enum Instruction: String {
        case noop = "noop"
        case fork = "fork"
        case swap = "swap"
    }
    let instruction:Instruction
    
    init(name:String) {
        switch(name) {
        case Instruction.fork.rawValue:
            self.instruction = .fork
        case Instruction.swap.rawValue:
            self.instruction = .swap
        default:
            self.instruction = .noop
        }
    }
}

extension VS2Controller: VS2Shader {
    func encode(to commandBuffer: MTLCommandBuffer, stack: VS2CIImageStack) {
        switch(instruction) {
        case .fork:
            let ciImage = stack.pop()
            stack.push(ciImage)
            stack.push(ciImage)
        case .swap:
            let ciImage1 = stack.pop()
            let ciImage2 = stack.pop()
            stack.push(ciImage1)
            stack.push(ciImage2)
        default:
            break
        }
    }
}

extension VS2Controller: CustomDebugStringConvertible {
    var debugDescription: String {
        return instruction.rawValue
    }
}

