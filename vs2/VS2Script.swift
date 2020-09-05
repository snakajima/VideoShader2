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
    let script:[String:Any]
    init(script:[String:Any]) {
        self.script = script
    }
    
    func encode() {
        guard let pipeline = script["pipeline"] as? [[String:Any]] else {
            print("no or invalid pipeline")
            return
        }
        for element in pipeline {
            if let filter = element["filter"] as? String {
                print("filter=", filter)
            }
        }
    }
}
