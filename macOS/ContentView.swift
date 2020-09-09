//
//  ContentView.swift
//  vs2Mac
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import SwiftUI

let s_script0 = [
    "pipeline":[[
        "filter": "chromaKey",
        "props":[
            "color":[1.0, 0.5, 0.0],
        ]
    ]]
]
let s_script4 = [
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
        "controller": "swap"
    ],[
        "blender": "maskedVariableBlur"
    ]]
]
struct ContentView: View {
    @State var script:[String:Any] = s_script0
    var body: some View {
        VStack {
            VS2View(script:$script)
                .edgesIgnoringSafeArea(.top)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Foo()
    }
}

struct Foo: View {
    @State var script1:[String:Any] = [
        "pipeline": [[
            "filter": "halftone",
            "props":[
                "radius":10,
            ]
        ]]
    ]
    @State var script2:[String:Any] = [
        "pipeline": [[
            "filter": "chromaKey",
            "props":[
                "hueMin":100.0,
                "hueMax":144.0,
                "minMax":0.4,
            ]
        ]]
    ]
    @State var script3:[String:Any] = [
        "pipeline": [[
            "filter": "chromaKey",
            "props":[
                "hueMin":100.0,
                "hueMax":144.0,
                "minMax":1.0,
            ]
        ]]
    ]
    @State var script4:[String:Any] = [
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
    var body: some View {
        VStack {
            HStack {
                VS2View(script:$script1)
                VS2View(script:$script2)
            }
            HStack {
                VS2View(script:$script3)
                VS2View(script:$script4)
            }
        }
    }}
