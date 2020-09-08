//
//  toone.metal
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/8/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" { namespace coreimage {

    float4 myColor(sample_t s) {

        return s.grba;
    }

}}

