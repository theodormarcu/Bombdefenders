//
//  AnimationActions.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 7/6/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import SpriteKit
class AnimationActions {
    // Explosion Texture Atlas
    private var atlas: SKTextureAtlas!
    private var textureAtlas: [SKTexture]!
    
    init() {
        // Explosion
        atlas = SKTextureAtlas(named: "ExplosionAnimation")
        textureAtlas = atlas.textureArray()
    }
    
    // explosion animation
    func startExplosionAnimation(point: CGPoint, scene: SKScene) {
        let explosion = SKSpriteNode(texture: textureAtlas[0])
        explosion.position = point
        explosion.zPosition = 4
        explosion.isUserInteractionEnabled = false
        scene.addChild(explosion)
        let timePerFrame = 0.02
        let animationAction = SKAction.animate(with: textureAtlas, timePerFrame: timePerFrame)
        explosion.run(animationAction, completion: {
            explosion.removeFromParent()
            explosion.removeAllActions()
        })
    }
    
    // "NUKE" explosion animation
    func startNukeExplosionAnimation(point: CGPoint, scene: SKScene) {
        let explosion = SKSpriteNode(texture: textureAtlas[0])
        explosion.position = point
        explosion.scale(to: CGSize(width: explosion.size.width * 5, height: explosion.size.height * 5))
        explosion.zPosition = 4
        scene.addChild(explosion)
        let timePerFrame = 0.02
        let animationAction = SKAction.animate(with: textureAtlas, timePerFrame: timePerFrame)
        explosion.run(animationAction, completion: {
            explosion.removeFromParent()
            explosion.removeAllActions()
        })
    }

}
