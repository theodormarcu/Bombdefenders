//
//  HumanSprite.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 7/2/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import SpriteKit

public class HumanSprite : SKSpriteNode {
    public static func newInstance() -> HumanSprite {
        let humanSprite = HumanSprite(imageNamed: "Player_Male")
        
        humanSprite.zPosition = 3
        humanSprite.physicsBody = SKPhysicsBody(circleOfRadius: humanSprite.size.width / 2)
        humanSprite.physicsBody?.categoryBitMask = HumanCategory
        humanSprite.physicsBody?.contactTestBitMask = BombCategory | WorldFrameCategory
        return humanSprite
    }
    
    public func update(deltaTime : TimeInterval) {
        
    }
}
