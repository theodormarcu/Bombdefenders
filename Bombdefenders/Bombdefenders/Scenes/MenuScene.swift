//
//  MenuScene.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 7/4/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation

import SpriteKit

class MenuScene : SKScene {
    
    let startButtonTexture = SKTexture(imageNamed: "ButtonStart")
    let startButtonPressedTexture = SKTexture(imageNamed: "ButtonStartPressed")
    let soundButtonTexture = SKTexture(imageNamed: "speaker_on")
    let soundButtonTextureOff = SKTexture(imageNamed: "speaker_off")
    let logoPaneTexture = SKTexture(imageNamed: "LogoPaneRed")
    
    let logoNode = SKLabelNode(fontNamed: "PixelDigivolve")
    var logoPane : SKSpriteNode! = nil
    var startButton : SKSpriteNode! = nil
    var soundButton : SKSpriteNode! = nil
    
    let highScoreNode = SKLabelNode(fontNamed: "PixelDigivolve")
    var copyrightLabel = SKLabelNode(fontNamed: "SanFranciscoText-LightItalic")
    
    var selectedButton : SKSpriteNode?
    
    override func sceneDidLoad() {
        // background
//        backgroundColor = #colorLiteral(red: 0.2039, green: 0.2863, blue: 0.3686, alpha: 1) /* #34495e */
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = 0
        addChild(background)
        
        //Setup logo - sprite initialized earlier
        logoPane = SKSpriteNode(texture: logoPaneTexture)
        logoPane.position = CGPoint(x: size.width / 2, y: size.height / 2 + 262)
        logoPane.zPosition = 1
        addChild(logoPane)
        logoNode.text = "Bombdefenders"
        //logoNode.fontColor = #colorLiteral(red: 0.9059, green: 0.298, blue: 0.2353, alpha: 1) /* #e74c3c */
        logoNode.fontColor = #colorLiteral(red: 0.9255, green: 0.9412, blue: 0.9451, alpha: 1) /* #ecf0f1 */
        logoNode.position = CGPoint(x: size.width / 2, y: size.height / 2 + 250)
        logoNode.fontSize = 40
        logoNode.zPosition = 2
        addChild(logoNode)
        
        //Setup start button
        startButton = SKSpriteNode(texture: startButtonTexture)
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        startButton.zPosition = 1
        addChild(startButton)
        
        let edgeMargin : CGFloat = 25
        //Setup sound button
        soundButton = SKSpriteNode(texture: SoundManager.sharedInstance.isMuted ? soundButtonTextureOff : soundButtonTexture)
        soundButton.position = CGPoint(x: size.width - soundButton.size.width / 2 - edgeMargin, y: soundButton.size.height / 2 + edgeMargin)
        soundButton.zPosition = 1
        addChild(soundButton)
        
        //Setup high score node
        let defaults = UserDefaults.standard
        
        let highScore = defaults.integer(forKey: ScoreKey)
        
        highScoreNode.text = "\(highScore)"
        highScoreNode.fontSize = 90
        highScoreNode.verticalAlignmentMode = .top
        highScoreNode.position = CGPoint(x: size.width / 2, y: startButton.position.y - startButton.size.height / 2 - 50)
        highScoreNode.zPosition = 1
        addChild(highScoreNode)
        
        // Copyright label
        copyrightLabel.text = "© Theodor Marcu, theodormarcu.com"
        copyrightLabel.fontSize = 10
        copyrightLabel.zPosition = 2
        copyrightLabel.position = CGPoint(x: size.width / 2, y: 10)
        addChild(copyrightLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if selectedButton != nil {
                handleStartButtonHover(isHovering: false)
                handleSoundButtonHover(isHovering: false)
            }
            
            if startButton.contains(touch.location(in: self)) {
                selectedButton = startButton
                handleStartButtonHover(isHovering: true)
            } else if soundButton.contains(touch.location(in: self)) {
                selectedButton = soundButton
                handleSoundButtonHover(isHovering: true)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            if selectedButton == startButton {
                handleStartButtonHover(isHovering: (startButton.contains(touch.location(in: self))))
            } else if selectedButton == soundButton {
                handleSoundButtonHover(isHovering: (soundButton.contains(touch.location(in: self))))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            if selectedButton == startButton {
                handleStartButtonHover(isHovering: false)
                
                if (startButton.contains(touch.location(in: self))) {
                    handleStartButtonClick()
                }
                
            } else if selectedButton == soundButton {
                handleSoundButtonHover(isHovering: false)
                
                if (soundButton.contains(touch.location(in: self))) {
                    handleSoundButtonClick()
                }
            }
        }
        
        selectedButton = nil
    }
    
    func handleStartButtonHover(isHovering : Bool) {
        if isHovering {
            startButton.texture = startButtonPressedTexture
        } else {
            startButton.texture = startButtonTexture
        }
    }
    
    func handleSoundButtonHover(isHovering : Bool) {
        if isHovering {
            soundButton.alpha = 0.5
        } else {
            soundButton.alpha = 1.0
        }
    }
    
    func handleStartButtonClick() {
//        print("start clicked")
//        let transition = SKTransition.fade(with: UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0), duration: 0.75)
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        view?.presentScene(gameScene, transition: transition)
    }
    
    func handleSoundButtonClick() {
        if SoundManager.sharedInstance.toggleMute() {
            //Is muted
            soundButton.texture = soundButtonTextureOff
        } else {
            //Is not muted
            soundButton.texture = soundButtonTexture
        }
    }
}
