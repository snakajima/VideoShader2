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
        "filter": "zoomBlur",
        "props":[
            "amount":10.0,
            "center":[800, 500]
        ]
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
            "filter": "colorClamp",
            "props":[
                "minComponents":[0.0, 0.0, 0.5, 0.0]
            ]
        ]]
    ]
    @State var script2:[String:Any] = [
        "pipeline": [[
            "filter": "gaussianBlur",
            "props":[
                "radius":10.0
            ]
        ]]
    ]
    @State var script3:[String:Any] = [
        "pipeline": [[
            "filter": "zoomBlur",
            "props":[
                "amount":10.0,
                "center":[800, 500]
            ]
        ]]
    ]
    @State var script4:[String:Any] = [
        "pipeline": [[
            "filter": "medianFilter",
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
