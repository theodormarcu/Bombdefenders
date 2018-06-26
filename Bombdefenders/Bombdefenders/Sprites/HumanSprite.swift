//
//  HumanSprite.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 6/25/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public class HumanSprite : SKShapeNode {
    private let movementSpeed : CGFloat = 100
    
    public static func newInstance() -> HumanSprite {
        let humanWidth = 40
        let humanHeight = 40
        let humanSprite = HumanSprite(rectOf: CGSize(width: humanWidth,
                                                    height: humanHeight))
        
        humanSprite.zPosition = 3
        humanSprite.fillColor = SKColor.red
        humanSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: humanWidth,
                                                               height: humanHeight))
        humanSprite.physicsBody?.categoryBitMask = HumanCategory
        humanSprite.physicsBody?.contactTestBitMask = BombCategory | WorldFrameCategory
        
        return humanSprite
    }
    
    public func update(deltaTime : TimeInterval) {
        if (position.x <= 20) {
            position.x += movementSpeed * CGFloat(deltaTime)
        } else{
            position.x -= movementSpeed * CGFloat(deltaTime)
        }
        
        
    }
}
