//
//  VS2Filter.swift
//  vs2
//
//  Created by SATOSHI NAKAJIMA on 9/5/20.
//  Copyright © 2020 SATOSHI NAKAJIMA. All rights reserved.
//

import Foundation

public protocol VS2Filter {
    func makeFilter(props:Any?) -> VS2Filter
}
