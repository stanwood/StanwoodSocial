//
//  LikeType.swift
//  Mach_Dich_Krass
//
//  Created by Tal Zion on 11/11/2016.
//  Copyright © 2016 Stanwood GmbH. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

