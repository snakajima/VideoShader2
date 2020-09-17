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
    
    func vector(from: VNHumanHandPoseObservation.JointName, to:VNHumanHandPoseObservation.JointName) -> CGVector {
        if let pointFrom = points[from],
           let pointTo = points[to] {
            return pointTo.location.vector(from: pointFrom.location)
        }
        return .zero
    }
}

extension VNRecognizedPoint {
    func distance(_ from:VNRecognizedPoint) -> CGFloat {
        let dx = self.location.x - from.location.x
        let dy = self.location.y - from.location.y
        return sqrt(dx * dx + dy * dy)
    }
}

extension CGPoint {
    func unnormalized(size:CGSize) -> CGPoint {
        return CGPoint(x: x * size.width, y: y * size.height)
    }
    func mixed(_ another:CGPoint, ratio:CGFloat) -> CGPoint {
        return CGPoint(x: x * (1-ratio) + another.x * ratio, y: y * (1-ratio) + another.y * ratio)
    }
    func vector(from:CGPoint) -> CGVector {
        return CGVector(dx: x - from.x, dy: y - from.y)
    }
}

extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
}

extension CGSize {
    func unnormalized(size:CGSize) -> CGSize {
        return CGSize(width: width * size.width, height: height * size.height)
    }
    func mixed(_ another:CGSize, ratio:CGFloat) -> CGSize {
        return CGSize(width: width * (1-ratio) + another.width * ratio, height: height * (1-ratio) + another.height * ratio)
    }
}

extension CGRect {
    func unnormalized(size:CGSize) -> CGRect {
        return CGRect(origin: origin.unnormalized(size: size), size: self.size.unnormalized(size: size))
    }
    func mixed(_ another:CGRect, ratio:CGFloat) -> CGRect {
        return CGRect(origin: origin.mixed(another.origin, ratio:ratio), size: size.mixed(another.size, ratio:ratio))
    }
}
