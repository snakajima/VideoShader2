//
//  VS2GaussianFilter.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation

class VS2GausiannFilter {
    var sigma = 1.0
}

extension VS2GausiannFilter: VS2Filter {
    func makeFilter(props: Any?) -> VS2Filter {
        let filter = VS2GausiannFilter()
        if let props = props as? [String:Any] {
            print("props", props)
            if let sigma = props["sigma"] as? Double {
                print("sigma", sigma)
                filter.sigma = sigma
            }
        }
        return filter
    }
}
