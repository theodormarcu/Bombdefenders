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
    private let movementSpeed : CGFloat = 100
    private var moveLeft : Bool
    
    init(moveLeft: Bool, playerTexture: SKTexture) {
        self.moveLeft = moveLeft
        super.init(texture: playerTexture, color: UIColor.clear, size: playerTexture.size())
        super.zPosition = 3
        super.physicsBody = SKPhysicsBody(circleOfRadius: playerTexture.size().height / 2)
        super.physicsBody?.categoryBitMask = HumanCategory
        super.physicsBody?.contactTestBitMask = BombCategory | WorldFrameCategory
        super.physicsBody?.collisionBitMask = FloorCategory
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(deltaTime : TimeInterval) {
        if (super.position.x <= 0) {
            super.position.x = 0
            self.changeDirection(moveLeft: false)
        } else if (super.position.x >= UIScreen.main.bounds.size.width) {
            super.position.x = UIScreen.main.bounds.size.width
            self.changeDirection(moveLeft: true)
        }
        if moveLeft {
            // Move left
            position.x -= movementSpeed * CGFloat(deltaTime)
            xScale = -1
        } else {
            // Move right
            position.x += movementSpeed * CGFloat(deltaTime)
            xScale = 1
        }
    }
    
    public func changeDirection(moveLeft: Bool) {
        self.moveLeft = moveLeft
    }
}
