//
//  ContentView.swift
//  vs2Mac
//
//  Created by SATOSHI NAKAJIMA on 9/4/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VS2CameraViewController()
            .edgesIgnoringSafeArea(.top)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
