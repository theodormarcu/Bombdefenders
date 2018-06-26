//
//  HumanSprite.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 6/25/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import SpriteKit

public class CatSprite : SKSpriteNode {
    public static func newInstance() -> CatSprite {
        let catSprite = CatSprite(imageNamed: "cat_one")
        
        catSprite.zPosition = 3
        catSprite.physicsBody = SKPhysicsBody(circleOfRadius: catSprite.size.width / 2)
        
        return catSprite
    }
    
    public func update(deltaTime : TimeInterval) {
        
    }
}
