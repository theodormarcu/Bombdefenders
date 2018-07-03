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
    
    init(moveLeft: Bool) {
        let texture = SKTexture(imageNamed: "Player_Male")
        self.moveLeft = moveLeft
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        super.zPosition = 3
        super.physicsBody = SKPhysicsBody(circleOfRadius: texture.size().width / 2)
        super.physicsBody?.categoryBitMask = HumanCategory
        super.physicsBody?.contactTestBitMask = BombCategory | WorldFrameCategory
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public static func newInstance() -> HumanSprite {
//        let humanSprite = HumanSprite(imageNamed: "Player_Male")
//        humanSprite.zPosition = 3
//        humanSprite.physicsBody = SKPhysicsBody(circleOfRadius: humanSprite.size.width / 2)
//        humanSprite.physicsBody?.categoryBitMask = HumanCategory
//        humanSprite.physicsBody?.contactTestBitMask = BombCategory | WorldFrameCategory
//        return humanSprite
//    }
//
    public func update(deltaTime : TimeInterval) {
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
