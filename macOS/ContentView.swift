//
//  ContentView.swift
//  vs2Mac
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import SwiftUI

private let s_script0 = [
    "pipeline": [[
        "filter": "halftone",
        "props":[
            "radius":10,
        ]
    ]]
]
private let s_script1 = [
    "pipeline": [[
        "filter": "chromaKey",
        "props":[
            "hueMin":100.0,
            "hueMax":144.0,
            "minMax":0.4,
        ]
    ],[
        "texture": "star"
    ],[
        "filter": "fourfoldTranslatedTile",
        "props":[
            "width":200.0,
            "center":[0, 0],
        ]
    ],[
        "controller": "swap"
    ],[
        "blender": "sourceOver"
    ]]
]
private let s_script2 = [
    "pipeline": [[
        "controller": "fork"
    ],[
        "filter": "gaussianBlur",
        "props":[
            "radius":10.0,
        ]
    ],[
        "blender": "differenceBlend"
    ],[
        "filter": "boolean",
        "props":[
            "range":[0.0, 0.2],
            "color1":[1, 1, 0, 1],
            "color2":[0, 0, 1, 1],
        ]
    ],[
        "texture": "star"
    ],[
        "blender": "sourceOver"
    ]]
]
private let s_script3 = [
    "pipeline": [[
        "controller": "fork"
    ],[
        "filter": "edgeWork",
        "props":[
            "radius":1.5,
        ]
    ],[
        "controller": "swap"
    ],[
        "filter": "toone",
    ],[
        "blender": "minimum"
    ]]
]
struct ContentView: View {
    @State var script:[String:Any] = s_script2
    @State var layer:CALayer? = nil
    var body: some View {
        VStack {
            VS2View(script:$script, layer:layer)
                .edgesIgnoringSafeArea(.top)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Foo()
    }
}

private struct Foo: View {
    @State var script0:[String:Any] = s_script0
    @State var script1:[String:Any] = s_script1
    @State var script2:[String:Any] = s_script2
    @State var script3:[String:Any] = s_script3
    @State var script4:[String:Any] = s_script2
    @State var script5:[String:Any] = s_script3
    @State var layer:CALayer? = nil
    var body: some View {
        VStack {
            HStack {
                VS2View(script:$script0, layer:layer)
                VS2View(script:$script1, layer:layer)
            }
            HStack {
                VS2View(script:$script2, layer:layer)
                VS2View(script:$script3, layer:layer)
            }
        }
    }}
