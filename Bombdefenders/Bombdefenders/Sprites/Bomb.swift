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
    weak var delegate: BombDelegate!
    private let random = GKARC4RandomSource()
    private var parentNode : SKNode!
    private var taps : Int!
    private let animations = AnimationActions() // Explosions
    
    init (parentNode: SKNode, parentScene: SKScene, bombType: String, bombTexture: SKTexture) {
        // Define Bomb
        self.parentNode = parentNode
        
        super.init(texture: bombTexture, color: UIColor.clear, size: bombTexture.size())
        super.position = CGPoint(x: parentScene.size.width / 2, y:  parentScene.size.height / 2)
        self.isUserInteractionEnabled = true

        // Bomb Dimensions
        // Used to be 60 x 100
        let bombWidth = super.size.width
        let bombHeight = super.size.height

        // Add Physics Body
        super.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bombWidth,
                                                             height: bombHeight))
        // Determine Random Spawn Position
        var randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: parentScene.size.width))
        if randomPosition < (bombWidth / 2) {
            randomPosition = (bombWidth / 2)
        }
        if randomPosition > (parentScene.size.width  - bombWidth / 2) {
            randomPosition = parentScene.size.width  - bombWidth / 2
        }
        super.position = CGPoint(x: randomPosition, y: parentScene.size.height)
        super.physicsBody?.categoryBitMask = BombCategory
        super.physicsBody?.contactTestBitMask = WorldFrameCategory
        super.physicsBody?.collisionBitMask = 0
        switch bombType {
        case "nukeBomb":
            super.name = "nukeBomb"
            self.physicsBody?.linearDamping = 6.0
            taps = 4
        case "fatBomb":
            super.name = "fatBomb"
            self.physicsBody?.linearDamping = 4.0
            taps = 2
        default:
            super.name = "bomb"
            taps = 1
        }
        

        // Add to the Scene

        super.zPosition = 5
    }
    
    public func spawnBomb() {
        parentNode.addChild(self)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getTaps() -> Int {
        return taps
    }
    
    public func subtractTaps() {
        taps = taps - 1
    }
    
    public func changeTexture(newTexture: SKTexture) {
        super.texture = newTexture
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.didClick(bomb: self)
    }
    
}

protocol BombDelegate: class {
    func didClick(bomb: Bomb)
}
