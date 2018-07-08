//
//  Bomb.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 7/7/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Bomb : SKSpriteNode {
    private let random = GKARC4RandomSource()
    private var parentNode : SKNode!
    init (parentNode: SKNode, parentScene: SKScene, bombType: ) {
        // Define Bomb
        self.parentNode = parentNode
        let bombTexture = SKTexture(imageNamed: "Bomb")
        super.init(texture: bombTexture, color: UIColor.clear, size: bombTexture.size())
        super.position = CGPoint(x: parentScene.size.width / 2, y:  parentScene.size.height / 2)
        super.name = "bomb"

        // Bomb Dimensions
        // Used to be 60 x 100
        let bombWidth = super.size.width
        let bombHeight = super.size.height

        // Add Physics Body
        super.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bombWidth,
                                                             height: bombHeight))
        // Determine Random Spawn Position
        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: parentScene.size.width))
        super.position = CGPoint(x: randomPosition, y: parentScene.size.height)
        super.physicsBody?.categoryBitMask = BombCategory
        super.physicsBody?.contactTestBitMask = WorldFrameCategory
        super.physicsBody?.collisionBitMask = 0
        // Add to the Scene
        super.zPosition = 2
    }
    
    public func spawnBomb() {
        parentNode.addChild(self)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
