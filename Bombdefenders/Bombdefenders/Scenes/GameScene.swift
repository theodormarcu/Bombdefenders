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
    // Game Wide Stuff
    private var lastUpdateTime : TimeInterval = 0
    private let utils = Utils() // Useful Random Function
    private let hud = HudNode() // Score, HighScore, and Countdown
    private let animations = AnimationActions() // Explosions
    private let worldNode = SKNode() // Node that contains all moving nodes
    private var gamePaused : Bool = true
    // Players
    // TODO Add this to a function.
    private var human1 : HumanSprite!
    private var human2 : HumanSprite!
    private var human3 : HumanSprite!
    private let movementSpeed : CGFloat = 100
    private let buffer: Int = Int(UIImage(imageLiteralResourceName: "Player_Male").size.width)
    private var lives : Int = 3
    
    // Spawner Variables
    private var currentBombSpawnTime : TimeInterval = 0
    private var bombSpawnRate : TimeInterval = 0.5
    private let random = GKARC4RandomSource()
    
    // Pause Game
    func pauseGame() {
        worldNode.isPaused = true
        physicsWorld.speed = 0
        gamePaused = true
    }
    
    // Resume Game
    func resumeGame() {
        worldNode.isPaused = false
        physicsWorld.speed = 1
        gamePaused = false
    }
    
    // Regular Bomb Spawner
//    private func spawnBomb() {
//
//        // Define Bomb
//        let bomb = SKSpriteNode(imageNamed: "Bomb")
//        bomb.position = CGPoint(x: size.width / 2, y:  size.height / 2)
//        bomb.name = "bomb"
//        
//        // Bomb Dimensions
//        // Used to be 60 x 100
//        let bombWidth = bomb.size.width
//        let bombHeight = bomb.size.height
//
//        
//        // Add Physics Body
//        bomb.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bombWidth,
//                                                             height: bombHeight))
//        // Determine Random Spawn Position
//        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
//        bomb.position = CGPoint(x: randomPosition, y: size.height)
//        bomb.physicsBody?.categoryBitMask = BombCategory
//        bomb.physicsBody?.contactTestBitMask = WorldFrameCategory
//
//        // Add to the Scene
//        bomb.zPosition = 2
//        worldNode.addChild(bomb)
//    }
    
    // Fat Bomb Spawner
    private func spawnFatBomb() {

        // Define Bomb
        let fatBomb = SKSpriteNode(imageNamed: "FatBomb")
        fatBomb.position = CGPoint(x: size.width / 2, y:  size.height / 2)
        fatBomb.name = "fatBomb"
        
        // Bomb Dimensions
        let bombWidth = fatBomb.size.width
        let bombHeight = fatBomb.size.height
        print(bombWidth)
        print(bombHeight)
        // Add Physics Body
        fatBomb.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bombWidth,
                                                             height: bombHeight))
        // Determine Random Spawn Position
        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        fatBomb.position = CGPoint(x: randomPosition, y: size.height)
        fatBomb.physicsBody?.categoryBitMask = BombCategory
        fatBomb.physicsBody?.contactTestBitMask = WorldFrameCategory
        fatBomb.physicsBody?.collisionBitMask = 0
        fatBomb.physicsBody?.linearDamping = 5.0
        // Add to the Scene
        fatBomb.zPosition = 2
        worldNode.addChild(fatBomb)
    }
    
    // Called when view appears
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // World Node
        addChild(worldNode)
        // HUD Setup
        hud.setup(size: size, scene: self)
        addChild(hud)
        // Start Countdown To Start
        hud.countdown()
    }
    
    // When Scene Loads
    override func sceneDidLoad() {
        // Background
        let background = SKSpriteNode(imageNamed: "Background_2")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 0
        addChild(background)

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
        let floorNode = SKSpriteNode(imageNamed: "RoadNew")
        floorNode.position = CGPoint(x: size.width / 2, y: floorNode.size.height / 2)
        floorNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width, y: 0))
        floorNode.zPosition = 1
        floorNode.physicsBody?.categoryBitMask = FloorCategory
        floorNode.physicsBody?.contactTestBitMask = BombCategory
        addChild(floorNode)
        
        // Spawn Player Heads
        // TODO Add this to a function
        human1 = HumanSprite(moveLeft: utils.randomBool(), playerTexture: SKTexture(imageNamed: "Player_Male"))
        human1.position = CGPoint(x: utils.randomizer(min: UInt32(buffer), max: UInt32(Int(self.size.width) - buffer)), y: floorNode.size.height / 2 + human1.size.height / 2)
        human2 = HumanSprite(moveLeft: utils.randomBool(), playerTexture: SKTexture(imageNamed: "Player_Female"))
        human2.position = CGPoint(x: utils.randomizer(min: UInt32(buffer), max: UInt32(Int(self.size.width) - buffer)), y: floorNode.size.height / 2 + human2.size.height / 2)
        human3 = HumanSprite(moveLeft: utils.randomBool(), playerTexture: SKTexture(imageNamed: "Player_Robot"))
        human3.position = CGPoint(x: utils.randomizer(min: UInt32(buffer), max: UInt32(Int(self.size.width) - buffer)), y: floorNode.size.height / 2 + human3.size.height / 2)
        // Add players to world node
        worldNode.addChild(human1)
        worldNode.addChild(human2)
        worldNode.addChild(human3)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            // If Touched Bomb...
            if node.name == "bomb" {
                animations.startExplosionAnimation(point: node.position, scene: self)
                if (lives > 0) {
                    hud.addPoint()
                }
                // Play Bomb Explosion Sound
                node.removeFromParent()
                if SoundManager.sharedInstance.isMuted {
                    return
                }
                run(SKAction.playSoundFileNamed("Retro_Explosion.wav", waitForCompletion: true))
            }
            if node.name == "fatBomb" {
                animations.startExplosionAnimation(point: node.position, scene: self)
                if (lives > 0) {
                    hud.addPoint()
                }
                // Play Bomb Explosion Sound
                node.removeFromParent()
                if SoundManager.sharedInstance.isMuted {
                    return
                }
                run(SKAction.playSoundFileNamed("Retro_Explosion.wav", waitForCompletion: true))
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Not Used
    }
    
    override func update(_ currentTime: TimeInterval) {
        // While game paused...
        if !gamePaused {
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
                let fatBombRand = utils.randomizer(min: 0, max: 30)
                if (hud.getScore() >= 15 && fatBombRand >= 20) {
                    spawnFatBomb()
                } else {
                    let bomb = Bomb(parentNode: worldNode, parentScene: self)
                    bomb.spawnBomb()
                }
            }
            
            // Make Humans Move
            human1.update(deltaTime: dt)
            human2.update(deltaTime: dt)
            human3.update(deltaTime: dt)
        }
    }
    
    // Detect Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == BombCategory) {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
        } else if (contact.bodyB.categoryBitMask == BombCategory) {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
        }
        
        if contact.bodyA.categoryBitMask == HumanCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
            animations.startExplosionAnimation(point: contact.contactPoint, scene: self)
            animations.startExplosionAnimation(point: (contact.bodyA.node?.position)!, scene: self)
            handleHumanCollision(contact: contact)
            return
        } else if contact.bodyB.categoryBitMask == HumanCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
            animations.startExplosionAnimation(point: contact.contactPoint, scene: self)
            animations.startExplosionAnimation(point: (contact.bodyB.node?.position)!, scene: self)
            handleHumanCollision(contact: contact)
            return
        }
        if contact.bodyA.categoryBitMask == FloorCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
            animations.startExplosionAnimation(point: contact.contactPoint, scene: self)
            // Play Explosion Sound
            if SoundManager.sharedInstance.isMuted {
                return
            }
            run(SKAction.playSoundFileNamed("Retro_Explosion.wav", waitForCompletion: true))
        } else if contact.bodyB.categoryBitMask == FloorCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
            animations.startExplosionAnimation(point: contact.contactPoint, scene: self)
            // Play Explosion Sound
            if SoundManager.sharedInstance.isMuted {
                return
            }
            run(SKAction.playSoundFileNamed("Retro_Explosion.wav", waitForCompletion: true))
        }
        
       
    }
    
    // Handle Human Collision
    func handleHumanCollision(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == HumanCategory {
            otherBody = contact.bodyB
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
        } else {
            otherBody = contact.bodyA
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
        }
        
        switch otherBody.categoryBitMask {
        case BombCategory:
            lives = lives - 1
            if (lives <= 0) {
                // Game Over
//                let transition = SKTransition.fade(with: UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0), duration: 0.75)
                hud.gameOver()
                pauseGame()
                for case let child as SKSpriteNode in worldNode.children {
                    animations.startExplosionAnimation(point: child.position, scene: self)
                    child.removeAllActions()
                    child.removeFromParent()
                    child.physicsBody = nil
                }
                let transition = SKTransition.fade(withDuration: 0.75)
                
                let gameScene = MenuScene(size: self.size)
                gameScene.scaleMode = self.scaleMode
                
                let wait = SKAction.wait(forDuration: 1)
                let action = SKAction.run {
                    self.view?.presentScene(gameScene, transition: transition)
                }
                self.run(SKAction.sequence([wait, action]))

            }
            // Play Explosion Sound
            if SoundManager.sharedInstance.isMuted {
                return
            }
            run(SKAction.playSoundFileNamed("Retro_Explosion.wav", waitForCompletion: true))
        case WorldFrameCategory:
            lives = lives - 1
            if (lives == 0) {
                hud.resetPoints()
            }
        default:
            // Just in case...
            print("Something hit the player?")
        }
    }
}
