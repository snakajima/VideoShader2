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

struct CALayerView: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<CALayerView>) -> NSView {
        let view = NSView()
        let layer = CAShapeLayer()
        view.layer = layer
        return view
    }
    
    func updateNSView(_ view: NSView, context: NSViewRepresentableContext<CALayerView>) {
        if let layer = view.layer as? CAShapeLayer {
            let path = CGMutablePath()
            path.move(to: CGPoint(x:0, y:0))
            path.addLine(to: CGPoint(x: 100, y: 100))
            path.addLine(to: CGPoint(x: 0, y: 100))
            path.closeSubpath()
            layer.path = path
            layer.strokeColor = NSColor.red.cgColor
            layer.fillColor = NSColor.green.cgColor
        }
    }
    
    class Coordinator: NSObject {
        let view: CALayerView
        init(_ view: CALayerView) {
            self.view = view
        }
    }
}

struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text(verbatim: "foo")
            CALayerView()
            Text(verbatim: "bar")
        }
    }
}

