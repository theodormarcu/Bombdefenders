//
//  SoundManager.swift
//  Bombdefenders
//
//  Created by Theodor Marcu on 7/4/18.
//  Copyright © 2018 Theodor Marcu. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager : NSObject, AVAudioPlayerDelegate {
    static let sharedInstance = SoundManager()
    
    var audioPlayer : AVAudioPlayer?
    
    //Music by Eric Matyas
    //
    //www.soundimage.org
    static private let track = "Background_Music"
    private(set) var isMuted = false
    private override init() {
        let defaults = UserDefaults.standard
        
        isMuted = defaults.bool(forKey: MuteKey)
    }
    
    public func startPlaying() {
        if !isMuted && (audioPlayer == nil || audioPlayer?.isPlaying == false) {
            let soundURL = Bundle.main.url(forResource: SoundManager.track, withExtension: "mp3")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
                audioPlayer?.delegate = self
            } catch {
                print("audio player failed to load")
                
                startPlaying()
            }
            
            audioPlayer?.prepareToPlay()
            
            audioPlayer?.play()

        } else {
            print("Audio player is already playing!")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //Just play the next track
        startPlaying()
    }
    
    func isSoundOff() -> Bool {
        return isMuted
    }
    
    func toggleMute() -> Bool {
        isMuted = !isMuted
        
        let defaults = UserDefaults.standard
        defaults.set(isMuted, forKey: MuteKey)
        defaults.synchronize()
        
        if isMuted {
            audioPlayer?.stop()
        } else {
            startPlaying()
        }
        
        return isMuted
    }
}
