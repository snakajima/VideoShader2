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

let s_layer:CALayer = { ()-> CALayer in
    let textLayer = CATextLayer()

    textLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 200, height: 50))
    textLayer.position = CGPoint(x: 100, y: 100)
    textLayer.string = "Hello World"
    textLayer.fontSize = 32
    textLayer.foregroundColor = NSColor.green.cgColor
    
    let shapeLayer = CAShapeLayer()
    let starPath = CGMutablePath()
    starPath.move(to: CGPoint(x: 81.5, y: 7.0))
    starPath.addLine(to: CGPoint(x: 101.07, y: 63.86))
    starPath.addLine(to: CGPoint(x: 163.0, y: 64.29))
    starPath.addLine(to: CGPoint(x: 113.16, y: 99.87))
    starPath.addLine(to: CGPoint(x: 131.87, y: 157.0))
    starPath.addLine(to: CGPoint(x: 81.5, y: 122.13))
    starPath.addLine(to: CGPoint(x: 31.13, y: 157.0))
    starPath.addLine(to: CGPoint(x: 49.84, y: 99.87))
    starPath.addLine(to: CGPoint(x: 0.0, y: 64.29))
    starPath.addLine(to: CGPoint(x: 61.93, y: 63.86))
    starPath.addLine(to: CGPoint(x: 81.5, y: 7.0))
    shapeLayer.path = starPath
    shapeLayer.strokeColor = CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    shapeLayer.fillColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    let rectanglePath = CGMutablePath()
               rectanglePath.move(to: CGPoint(x: 81.5, y: 7.0))
               rectanglePath.addLine(to: CGPoint(x: 163.0, y: 7.0))
               rectanglePath.addLine(to: CGPoint(x: 163.0, y: 82.0))
               rectanglePath.addLine(to: CGPoint(x: 163.0, y: 157.0))
               rectanglePath.addLine(to: CGPoint(x: 163.0, y: 157.0))
               rectanglePath.addLine(to: CGPoint(x: 82.0, y: 157.0))
               rectanglePath.addLine(to: CGPoint(x: 0.0, y: 157.0))
               rectanglePath.addLine(to: CGPoint(x: 0.0, y: 157.0))
               rectanglePath.addLine(to: CGPoint(x: 0.0, y: 82.0))
               rectanglePath.addLine(to: CGPoint(x: 0.0, y: 7.0))
               rectanglePath.addLine(to: CGPoint(x: 81.5, y: 7.0))
    let pathAnimation = CABasicAnimation(keyPath: "path")
    pathAnimation.toValue = rectanglePath
    pathAnimation.duration = 0.75
    pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    pathAnimation.autoreverses = true
    pathAnimation.repeatCount = .greatestFiniteMagnitude
    shapeLayer.add(pathAnimation, forKey: "pathAnimation")
    
    let layer = CALayer()
    layer.addSublayer(shapeLayer)
    layer.addSublayer(textLayer)
    return layer
}()

struct ContentView: View {
    @State var script:[String:Any] = s_script2
    var body: some View {
        VStack {
            VS2View(script:$script, layer:s_layer)
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
    @State var layer:CALayer? = s_layer
    var body: some View {
        VStack {
            HStack {
                VS2View(script:$script0, layer:s_layer)
                VS2View(script:$script1, layer:layer)
            }
            HStack {
                VS2View(script:$script2, layer:layer)
                VS2View(script:$script3, layer:layer)
            }
        }
    }}
