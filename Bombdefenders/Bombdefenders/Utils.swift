//
//  Utils.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 7/6/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import SpriteKit
class Utils {
    // random true/false generator
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    // Random Generator between min and max
    func randomizer(min: UInt32, max: UInt32) -> CGFloat {
        
        assert(min < max)
        return CGFloat(arc4random_uniform(max - min)  + min)
    }
}


