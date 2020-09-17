//
//  HandGestureAnalyzer.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/17/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Vision

struct HandGectureAnalyzer {
    let observation:VNHumanHandPoseObservation
    let points:[VNHumanHandPoseObservation.JointName : VNRecognizedPoint]
    lazy var center:CGPoint = {
        var sum = CGPoint.zero
        for (_, point) in points {
            sum.x += point.location.x
            sum.y += point.location.y
        }
        let count = CGFloat(points.count)
        return CGPoint(x: sum.x / count, y: sum.y / count)
    }()
    
    lazy var bounds:CGRect = {
        var origin = points.first!.value.location
        var extend = origin
        for (_, point) in points {
            origin.x = min(origin.x, point.location.x)
            origin.y = min(origin.y, point.location.y)
            extend.x = max(extend.x, point.location.x)
            extend.y = max(extend.y, point.location.y)
        }
        return CGRect(origin: origin, size: CGSize(width: extend.x - origin.x, height: extend.y - origin.y))
    }()
    
    init(observation:VNHumanHandPoseObservation) throws {
        self.observation = observation
        self.points = try observation.recognizedPoints(.all)
    }
}
