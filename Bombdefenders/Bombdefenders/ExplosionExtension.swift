//
//  ExplosionExtension.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 7/3/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import SpriteKit

extension SKTextureAtlas {
    func textureArray() -> [SKTexture] {
        var textureNames = self.textureNames as! [String]
        
        // They need to be sorted because there's not guarantee the
        // textures will be in the correct order.
        textureNames.sort { $0 < $1 }
        return textureNames.map { SKTexture(imageNamed: $0) }
    }
}
