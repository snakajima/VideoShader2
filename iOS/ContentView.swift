//
//  ContentView.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var script:[String:Any] = [
        "pipeline": [[
            "controller": "fork",
        ],[
            "filter": "hueAdjust",
            "props":[
                "angle":3.14
            ]
        ],[
            "filter": "edges",
        ],[
            "Xfilter": "gaussianBlur",
            "props":[
                "radius":10
            ]
        ],[
            "filter": "exposureAdjust",
            "props":[
                "ev":5.0
            ]
        ],[
            "Xfilter": "colorInvert",
        ],[
            "blender": "maximumCompositing",
        /*
        ],[
            "filter": "sobel",
        */
        ]]
    ]
    var body: some View {
        VStack {
            VS2View(script:$script)
                .edgesIgnoringSafeArea(.top)
        }
    }}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
