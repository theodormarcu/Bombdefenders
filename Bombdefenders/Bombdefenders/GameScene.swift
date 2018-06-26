//
//  GameScene.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 6/24/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var lastUpdateTime : TimeInterval = 0
    
    // Spawner Variables
    private var currentBombSpawnTime : TimeInterval = 0
    private var bombSpawnRate : TimeInterval = 0.5
    private let random = GKARC4RandomSource()
    var counter = 0
    
    // Bomb Spawner
    func spawnBomb() {
        // Bomb Dimensions
        let bombWidth = 60
        let bombHeight = 100
        
        // Define Bomb
        let bomb = SKShapeNode(rectOf: CGSize(width: bombWidth,
                                              height: bombHeight))
        bomb.position = CGPoint(x: size.width / 2, y:  size.height / 2)
        bomb.fillColor = SKColor.blue
        bomb.name = "bomb"
        // Add Physics Body
        bomb.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bombWidth,
                                                             height: bombHeight))
        // Determine Random Spawn Position
        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        bomb.position = CGPoint(x: randomPosition, y: size.height)
        bomb.physicsBody?.categoryBitMask = BombCategory
        bomb.physicsBody?.contactTestBitMask = WorldFrameCategory
        bomb.physicsBody?.collisionBitMask = 0
        // Add to the Scene
        addChild(bomb)
    }
    
    override func sceneDidLoad() {
        
        // Set Up World Frame (To Delete Stuff)
        var worldFrame = frame
        worldFrame.origin.x -= 100
        worldFrame.origin.y -= 100
        worldFrame.size.height += 200
        worldFrame.size.width += 200
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
        self.physicsWorld.contactDelegate = self
        self.physicsBody?.categoryBitMask = WorldFrameCategory
        
        // Start Timer
        self.lastUpdateTime = 0
        
        // Add Floor
        let floorNode = SKShapeNode(rectOf: CGSize(width: size.width, height: 5))
        floorNode.position = CGPoint(x: size.width / 2, y: 50)
        floorNode.fillColor = SKColor.red
        floorNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width, y: 0))
        // Add Bounce
//        floorNode.physicsBody?.restitution = 0.3
        floorNode.physicsBody?.categoryBitMask = FloorCategory
        floorNode.physicsBody?.contactTestBitMask = BombCategory
        addChild(floorNode)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if node.name == "bomb" {
                print("Bomb Touched " + String(counter))
                node.removeFromParent()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Update the Spawn Timer
        currentBombSpawnTime += dt
        
        if currentBombSpawnTime > bombSpawnRate {
            currentBombSpawnTime = 0
            spawnBomb()
            counter += 1
        }
    }
    
    // Detect Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == BombCategory) {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
        } else if (contact.bodyB.categoryBitMask == BombCategory) {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
        }
        if contact.bodyA.categoryBitMask == WorldFrameCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
        } else if contact.bodyB.categoryBitMask == WorldFrameCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
        }
    }
}
