//
//  ContentView.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import SwiftUI

let s_script0 = [
    "pipeline":[[
        /*
        "filter": "toone",
        "props":[
            "minComponents":[0.0, 0.0, 0.0, 0.0],
            "maxComponents":[0.5, 1.0, 1.0, 1.0]
        ]
         */
    ]]
]

struct ContentView: View {
    @State var script:[String:Any] = s_script0
    var body: some View {
        VStack {
            VS2View(script:$script)
                .edgesIgnoringSafeArea(.all)
        }
    }}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
