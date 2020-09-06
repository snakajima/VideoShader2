//
//  VS2Script.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation
import Metal

class VSScript {
    static let templates:[String:VS2Operator] = [
        "gaussianBlur": VS2GaussianFilter()
    ]
    let script:[String:Any]
    var operators = [VS2Operator]()
    
    init(script:[String:Any]) {
        self.script = script
    }
    
    func compile() {
        guard let pipeline = script["pipeline"] as? [[String:Any]] else {
            print("no or invalid pipeline")
            return
        }
        operators.removeAll()
        for element in pipeline {
            if let key = element["filter"] as? String {
                print("key=", key)
                if let template = Self.templates[key] {
                    operators.append(template.makeFilter(props: element["props"]))
                }
            }
        }
        print("operators", operators)
    }
}
