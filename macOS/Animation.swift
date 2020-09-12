//
//  Animation.swift
//  vs2Mac
//
//  Created by SATOSHI NAKAJIMA on 9/11/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import SwiftUI
import MetalKit

struct Animation: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<Animation>) -> NSView {
        let view = NSTextView()
        view.string = "Hello World"
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<Animation>) {
    }
    
    class Coordinator: NSObject {
        let view: Animation
        init(_ view: Animation) {
            self.view = view
        }
    }
}

struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text(verbatim: "foo")
            Animation()
            Text(verbatim: "bar")
        }
    }
}

