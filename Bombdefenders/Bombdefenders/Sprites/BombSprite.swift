//
//  BombSprite.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 6/24/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class BombSprite: SKShapeNode {
    // Bomb Class Variables
    private var bombWidth: Int
    private var bombHeight: Int
    private var bombNode: SKShapeNode
    private var bombName: String
    
    init(size: CGSize) {
        bombWidth = 40
        bombHeight = 60
        bombNode = SKShapeNode(rectOf: CGSize(width: bombWidth,
                                              height: bombHeight))
        bombNode.position = CGPoint(x: size.width / 2, y:  size.height / 2)
        bombNode.fillColor = SKColor.blue
        bombNode.name = "bomb"
        // Add Physics Body
        bombNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bombWidth,
                                                             height: bombHeight))
        // Determine Random Spawn Position
        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        bombNode.position = CGPoint(x: randomPosition, y: size.height)
        bombNode.physicsBody?.categoryBitMask = BombCategory
        bombNode.physicsBody?.contactTestBitMask = WorldFrameCategory
        bombNode.physicsBody?.collisionBitMask = 0    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
