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

    half4 toone(sample_h s) {
        half y = dot(s.rbg, half3(0.3, 0.59, 0.11));
        half z = 1.0h;
        z = (y < 9.2h/10.0h) ? 8.0h/10.0h+(y-9.0h/10.0h)*10.0h : z;
        z = (y < 9.0h/10.0h) ? 8.0h/10.0h : z;
        z = (y < 7.2h/10.0h) ? 6.0h/10.0h+(y-7.0h/10.0h)*10.0h : z;
        z = (y < 7.0h/10.0h) ? 6.0h/10.0h : z;
        z = (y < 5.2h/10.0h) ? 4.0h/10.0h+(y-5.0h/10.0h)*10.0h : z;
        z = (y < 5.0h/10.0h) ? 4.0h/10.0h : z;
        z = (y < 3.2h/10.0h) ? 2.0h/10.0h+(y-3.0h/10.0h)*10.0h : z;
        z = (y < 3.0h/10.0h) ? 2.0h/10.0h : z;
        z = (y < 1.2h/10.0h) ? (y-1.0/10.0h)*10.0h : z;
        z = (y < 1.0h/10.0h) ? 0.0h : z;
        z = z / y;
        return half4(s.rgb * z, s.a);
    }

    half4 mono(sample_h s, float3 color) {
        half v = dot(s.rbg, half3(0.3, 0.59, 0.11));
        return half4(v * color.x, v * color.y, v * color.z, 1.0); // s.bgra;
    }

    half4 mosaic(sampler_h src, float length) {
        float2 coord = src.coord();
        uint x = coord.x;
        uint y = coord.y;
        x = x - x % uint(length);
        y = y - y % uint(length);
        half4 s = src.sample(float2(x, y));
        return s;
    }
}}

