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
    
    // Human
    private var human : HumanSprite!
    private let movementSpeed : CGFloat = 100

    // Spawner Variables
    private var currentBombSpawnTime : TimeInterval = 0
    private var bombSpawnRate : TimeInterval = 0.5
    private let random = GKARC4RandomSource()

    
    // Explosion Texture Atlas
    private var atlas: SKTextureAtlas!
    private var textureAtlas: [SKTexture]!
    
    // random true/false generator
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }

    
    // explosion animation
    func startExplosionAnimation(point: CGPoint) {
        let explosion = SKSpriteNode(texture: textureAtlas[0])
        explosion.position = point
        explosion.zPosition = 4
        self.addChild(explosion)
        let timePerFrame = 0.02
        let animationAction = SKAction.animate(with: textureAtlas, timePerFrame: timePerFrame)
        explosion.run(animationAction, completion: {
            explosion.removeFromParent()
            explosion.removeAllActions()
        })
    }
    
    // Bomb Spawner
    func spawnBomb() {
        // Bomb Dimensions
        let bombWidth = 60
        let bombHeight = 100
        
        // Define Bomb
        let bomb = SKSpriteNode(imageNamed: "Bomb")
        bomb.position = CGPoint(x: size.width / 2, y:  size.height / 2)
        
        bomb.name = "bomb"
        // Add Physics Body
        bomb.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bombWidth,
                                                             height: bombHeight))
        // Determine Random Spawn Position
        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        bomb.position = CGPoint(x: randomPosition, y: size.height)
        bomb.physicsBody?.categoryBitMask = BombCategory
        bomb.physicsBody?.contactTestBitMask = WorldFrameCategory
//        bomb.physicsBody?.collisionBitMask = 0
        // Add to the Scene
        bomb.zPosition = 2
        addChild(bomb)
    }
    
    // Human Spawner
    func spawnHuman() {
        if let currentHuman = human, children.contains(currentHuman) {
            human.removeFromParent()
            human.removeAllActions()
            human.physicsBody = nil
        }
        
        human = HumanSprite(moveLeft: randomBool())
        human.position = CGPoint(x: size.width / 2, y: 70)
        addChild(human)
    }
    
    override func sceneDidLoad() {
        // background
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 0
        addChild(background)
        // explosion
        atlas = SKTextureAtlas(named: "ExplosionAnimation")
        textureAtlas = atlas.textureArray()
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
        
        // Add Floor (Road)
        let floorNode = SKSpriteNode(imageNamed: "Road")
        floorNode.position = CGPoint(x: size.width / 2, y: floorNode.size.height / 2)
        floorNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width, y: 0))
        floorNode.zPosition = 1
        floorNode.physicsBody?.categoryBitMask = FloorCategory
        floorNode.physicsBody?.contactTestBitMask = BombCategory
        addChild(floorNode)
        
        spawnHuman()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if node.name == "bomb" {
                startExplosionAnimation(point: node.position)
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
        }
        

        if (human.position.x <= 0) {
            human.position.x = 0
            human.changeDirection(moveLeft: false)
        } else if (human.position.x >= size.width) {
            human.position.x = size.width
            human.changeDirection(moveLeft: true)
        }
        human.update(deltaTime: dt)
        
    }
    
    // Detect Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == BombCategory) {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
        } else if (contact.bodyB.categoryBitMask == BombCategory) {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
        }
        
//        if contact.bodyA.categoryBitMask == HumanCategory || contact.bodyB.categoryBitMask == HumanCategory {
//            handleHumanCollision(contact: contact)
//
//            return
//        }
        if contact.bodyA.categoryBitMask == HumanCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
            startExplosionAnimation(point: contact.contactPoint)
            startExplosionAnimation(point: human.position)
            handleHumanCollision(contact: contact)
            return
        } else if contact.bodyB.categoryBitMask == HumanCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
            startExplosionAnimation(point: contact.contactPoint)
            startExplosionAnimation(point: human.position)
            handleHumanCollision(contact: contact)
            return
        }
        if contact.bodyA.categoryBitMask == FloorCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
            startExplosionAnimation(point: contact.contactPoint)
        } else if contact.bodyB.categoryBitMask == FloorCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
            startExplosionAnimation(point: contact.contactPoint)
        }
        
       
    }
    
    // Handle Human Collision
    func handleHumanCollision(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == HumanCategory {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case BombCategory:
            print("rain hit the player")
            spawnHuman()
            
        case WorldFrameCategory:
            spawnHuman()
        default:
            print("Something hit the player")
        }
    }
}
