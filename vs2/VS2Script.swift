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
    static let templates:[String:VS2Filter] = [
        "gaussianBlur": VS2GausiannFilter()
    ]
    let script:[String:Any]
    var filters = [VS2Filter]()
    
    init(script:[String:Any]) {
        self.script = script
    }
    
    func compile() {
        guard let pipeline = script["pipeline"] as? [[String:Any]] else {
            print("no or invalid pipeline")
            return
        }
        var filters = [VS2Filter]()
        for element in pipeline {
            if let key = element["filter"] as? String {
                print("key=", key)
                if let template = Self.templates[key] {
                    print("template=", template, element["props"])
                    let filter = template.makeFilter(props: element["props"])
                    filters.append(filter)
                }
            }
        }
        self.filters = filters
        print("filters", self.filters)
    }
}
