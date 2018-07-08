//
//  HudNode.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 7/4/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation

import SpriteKit

class HudNode : SKNode {
    private let scoreKey = "BOMBDEFENDERS_HIGHSCORE"
    private let scoreNode = SKLabelNode(fontNamed: "PixelDigivolve")
    private(set) var score : Int = 0
    private var highScore : Int = 0
    private var showingHighScore = false
    private let countdownLabel = SKLabelNode(fontNamed: "PixelDigivolve")
    private var sceneSize : CGSize!
    private var count : Int = 3
    private var callingScene : GameScene!
    private let gameOverLabel = SKLabelNode(fontNamed: "PixelDigivolve")
    
    //Setup hud here
    public func setup(size: CGSize, scene: GameScene) {
        sceneSize = size
        callingScene = scene
        let defaults = UserDefaults.standard
        
        highScore = defaults.integer(forKey: scoreKey)
        
        scoreNode.text = "\(score)"
        scoreNode.fontSize = 70
        scoreNode.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreNode.zPosition = 1

    }
    
    public func addPoint() {
        score += 1
        
        updateScoreboard()
        
        if score > highScore {
            
            let defaults = UserDefaults.standard
            
            defaults.set(score, forKey: scoreKey)
            
            if !showingHighScore {
                showingHighScore = true
                
                scoreNode.run(SKAction.scale(to: 1.25, duration: 0.25))
                // #colorLiteral(red: 0.9451, green: 0.7686, blue: 0.0588, alpha: 1) /* #f1c40f */
                scoreNode.fontColor = #colorLiteral(red: 0.9451, green: 0.7686, blue: 0.0588, alpha: 1)
            }
        }
    }
    
    public func resetPoints() {
        score = 0
        
        updateScoreboard()
        
        if showingHighScore {
            showingHighScore = false
            
            scoreNode.run(SKAction.scale(to: 1.0, duration: 0.25))
            scoreNode.fontColor = SKColor.white
        }
    }
    
    private func updateScoreboard() {
        scoreNode.text = "\(score)"
    }
    
    func countdown() {
        callingScene.pauseGame()
        // Add label
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.verticalAlignmentMode = .baseline
        countdownLabel.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
        countdownLabel.fontSize = 50
        countdownLabel.zPosition = 100
        countdownLabel.text = "\(count)"
        
        addChild(countdownLabel)
        
        let counterDecrement = SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                                  SKAction.run(countdownAction)])
        
        run(SKAction.sequence([SKAction.repeat(counterDecrement, count: 4),
                               SKAction.run(endCountdown)]))
        
    }
    
    public func countdownAction() {
        count = count - 1
        if (count <= 0) {
            countdownLabel.text = "Go!"
        } else {
            countdownLabel.text = "\(count)"
        }
    }
    
    public func endCountdown() {
        countdownLabel.removeFromParent()
        callingScene.resumeGame()
        addChild(scoreNode)
    }
    
    public func gameOver() {
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.verticalAlignmentMode = .baseline
        gameOverLabel.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
        gameOverLabel.fontSize = 50
        gameOverLabel.zPosition = 100
        gameOverLabel.text = "Game Over"
        addChild(gameOverLabel)
    }
    
    public func getScore() -> Int {
        return score
    }
}
