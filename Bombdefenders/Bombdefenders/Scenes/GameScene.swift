//
//  GameScene.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 6/24/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, BombDelegate {
    // Game Wide Stuff
    private var lastUpdateTime : TimeInterval = 0
    private let utils = Utils() // Useful Random Function
    private let hud = HudNode() // Score, HighScore, and Countdown
    private let animations = AnimationActions() // Explosions
    private let worldNode = SKNode() // Node that contains all moving nodes
    private var gamePaused : Bool = true
    private var nukeSpawned : Bool = false
    private let safeAreaInsets = GameViewController.getSafeAreaInsets()

    // Players
    // TODO Add this to a function.
    private var human1 : HumanSprite!
    private let human1Texture = SKTexture(imageNamed: "Player_Male")
    private var human2 : HumanSprite!
    private let human2Texture = SKTexture(imageNamed: "Player_Female")
    private var human3 : HumanSprite!
    private let human3Texture = SKTexture(imageNamed: "Player_Robot")
    private let movementSpeed : CGFloat = 100
    private var buffer: Int = 0
    private var lives : Int = 3
    
    // Bomb Spawner Variables and Textures
    private var currentBombSpawnTime : TimeInterval = 0
    private var bombSpawnRate : TimeInterval = 0.5
    private let random = GKARC4RandomSource()
    private let bombTexture = SKTexture(imageNamed: "Bomb")
    private let fatBombTexture = SKTexture(imageNamed: "FatBomb")
    private let fatBombCrackedTexture = SKTexture(imageNamed: "FatBombCracked")
    private let nukeBombTexture = SKTexture(imageNamed: "NukeBomb")
    private let nukeBombCracked1Texture = SKTexture(imageNamed: "NukeBombCracked1")
    private let nukeBombCracked2Texture = SKTexture(imageNamed: "NukeBombCracked2")
    private let nukeBombCracked3Texture = SKTexture(imageNamed: "NukeBombCracked3")
    
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
    
    func didClick(bomb: Bomb) {

        bomb.subtractTaps()
        // If fatbomb, change texture
        if (bomb.name == "fatBomb" && bomb.getTaps() == 1) {
            bomb.changeTexture(newTexture: fatBombCrackedTexture)
        }
        // If nukeBomb, change texture
        if (bomb.name == "nukeBomb") {
            switch bomb.getTaps() {
            case 3:
                bomb.changeTexture(newTexture: nukeBombCracked1Texture)
            case 2:
                bomb.changeTexture(newTexture: nukeBombCracked2Texture)
            default:
                bomb.changeTexture(newTexture: nukeBombCracked3Texture)
            }
        }
        // Check if enough taps
        if (bomb.getTaps() <= 0) {
            if (bomb.name == "nukeBomb") {
                animations.startNukeExplosionAnimation(point: bomb.position, scene: self)
                nukeSpawned = false
            } else {
                animations.startExplosionAnimation(point: bomb.position, scene: self)
            }
            // Increase Score
            if (lives > 0) {
                hud.addPoint()
            }
            // Play Bomb Explosion Sound
            bomb.removeFromParent()
            if SoundManager.sharedInstance.isMuted {
                return
            }
            run(SKAction.playSoundFileNamed("Retro_Explosion.wav", waitForCompletion: true))
        }
    }
    
    // Called when view appears
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideAd"), object: nil)
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
        buffer = Int(human1Texture.size().width)
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
        floorNode.position = CGPoint(x: size.width / 2, y: safeAreaInsets.bottom * 1.5 + floorNode.size.height / 2)
        floorNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width, y: 0))
        floorNode.zPosition = 1
        floorNode.physicsBody?.categoryBitMask = FloorCategory
        floorNode.physicsBody?.contactTestBitMask = BombCategory
        addChild(floorNode)
        
        // Spawn Player Heads
        // TODO Add this to a function
        human1 = HumanSprite(moveLeft: utils.randomBool(), playerTexture: human1Texture)
        human1.position = CGPoint(x: utils.randomizer(min: UInt32(buffer), max: UInt32(Int(self.size.width) - buffer)), y: safeAreaInsets.bottom * 1.5 + floorNode.size.height / 2 + human1.size.height / 2)
        human2 = HumanSprite(moveLeft: utils.randomBool(), playerTexture: human2Texture)
        human2.position = CGPoint(x: utils.randomizer(min: UInt32(buffer), max: UInt32(Int(self.size.width) - buffer)), y: safeAreaInsets.bottom * 1.5 + floorNode.size.height / 2 + human2.size.height / 2)
        human3 = HumanSprite(moveLeft: utils.randomBool(), playerTexture: human3Texture)
        human3.position = CGPoint(x: utils.randomizer(min: UInt32(buffer), max: UInt32(Int(self.size.width) - buffer)), y: safeAreaInsets.bottom * 1.5 + floorNode.size.height / 2 + human3.size.height / 2)
        // Add players to world node
        worldNode.addChild(human1)
        worldNode.addChild(human2)
        worldNode.addChild(human3)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Not Used
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
                
                if (!nukeSpawned) {
                    if (hud.getScore() > 0 && hud.getScore() % 25 == 0) {
                        nukeSpawned = true
                        let nukeBomb = Bomb(parentNode: worldNode, parentScene: self,
                                            bombType: "nukeBomb", bombTexture: nukeBombTexture)
                        nukeBomb.delegate = self
                        nukeBomb.spawnBomb()
                    } else if (hud.getScore() >= 15 && fatBombRand >= 20) {
                        let fatBomb = Bomb(parentNode: worldNode, parentScene: self,
                                           bombType: "fatBomb", bombTexture: fatBombTexture)
                        fatBomb.delegate = self
                        fatBomb.spawnBomb()
                    } else {
                        let bomb = Bomb(parentNode: worldNode, parentScene: self,
                                        bombType: "regularBomb", bombTexture: bombTexture)
                        bomb.delegate = self
                        bomb.spawnBomb()
                    }
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
            if (contact.bodyB.node?.name == "nukeBomb") {
                animations.startNukeExplosionAnimation(point: contact.contactPoint, scene: self)
                lives = 0
            }
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
            animations.startExplosionAnimation(point: contact.contactPoint, scene: self)
            animations.startExplosionAnimation(point: (contact.bodyA.node?.position)!, scene: self)
            handleHumanCollision(contact: contact)
            return
        } else if contact.bodyB.categoryBitMask == HumanCategory {
            if (contact.bodyA.node?.name == "nukeBomb") {
                animations.startNukeExplosionAnimation(point: contact.contactPoint, scene: self)
                lives = 0
            }
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
            animations.startExplosionAnimation(point: contact.contactPoint, scene: self)
            animations.startExplosionAnimation(point: (contact.bodyB.node?.position)!, scene: self)
            handleHumanCollision(contact: contact)
            return
        }
        if contact.bodyA.categoryBitMask == FloorCategory {
            if (contact.bodyB.node?.name == "nukeBomb") {
                animations.startNukeExplosionAnimation(point: contact.contactPoint, scene: self)
                lives = 0
            }
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
            if (contact.bodyA.node?.name == "nukeBomb") {
                animations.startNukeExplosionAnimation(point: contact.contactPoint, scene: self)
                lives = 0
            }
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
