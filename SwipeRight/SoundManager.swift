//
//  SoundManager.swift
//  SwipeRight!
//
//  Created by Matthew Barth on 7/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import AVFoundation

enum Sound {
  case Correct
  case Incorrect
  case AbilityPoint
  case AbilityUse
  case GameOver
}


class SoundManager: NSObject {
  
  let correctSound = NSBundle.mainBundle().pathForResource("correct", ofType: "wav")
  let incorrectSound = NSBundle.mainBundle().pathForResource("incorrect", ofType: "wav")
  let abilityPointSound = NSBundle.mainBundle().pathForResource("ability_point", ofType: "wav")
  let abilityUseSound = NSBundle.mainBundle().pathForResource("ability_use", ofType: "wav")
  let gameOverSound = NSBundle.mainBundle().pathForResource("game_over", ofType: "wav")
  var correctPlayer: AVAudioPlayer?
  var incorrectPlayer: AVAudioPlayer?
  var abilityUsePlayer: AVAudioPlayer?
  var abilityPointPlayer: AVAudioPlayer?
  var gameOverPlayer: AVAudioPlayer?

  static var defaultManager = SoundManager()
  
  var muted: Bool {
    get {
      if let first = UserDefaultsManager.sharedManager.getObjectForKey("muted") as? Bool {
        return first
      } else {
        return false
      }
    }
    set (newValue) {
      UserDefaultsManager.sharedManager.setValueAtKey("muted", value: newValue)
    }
  }
  
  func shutDownSoundSystem() {
    self.gameOverPlayer = nil
    self.abilityPointPlayer = nil
    self.abilityUsePlayer = nil
    self.correctPlayer = nil
    self.incorrectPlayer = nil
  }
  
  func loadSoundFiles() {
    if !muted {
      if let correctSound = correctSound, incorrectSound = incorrectSound, abilityUseSound = abilityUseSound, abilityPointSound = abilityPointSound, gameOverSound = gameOverSound {
        let correctURL = NSURL(fileURLWithPath: correctSound), incorrectURL = NSURL(fileURLWithPath: incorrectSound), abilityUseURL = NSURL(fileURLWithPath: abilityUseSound), abilityPointURL = NSURL(fileURLWithPath: abilityPointSound), gameOverURL = NSURL(fileURLWithPath: gameOverSound)
        do {
          correctPlayer = try AVAudioPlayer(contentsOfURL: correctURL)
          incorrectPlayer = try AVAudioPlayer(contentsOfURL: incorrectURL)
          abilityUsePlayer = try AVAudioPlayer(contentsOfURL: abilityUseURL)
          abilityPointPlayer = try AVAudioPlayer(contentsOfURL: abilityPointURL)
          gameOverPlayer = try AVAudioPlayer(contentsOfURL: gameOverURL)
          try AVAudioSession.sharedInstance().setActive(true)
          try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch {
          print("Error loading sound files")
        }
        gameOverPlayer?.prepareToPlay()
        incorrectPlayer?.prepareToPlay()
        correctPlayer?.prepareToPlay()
        abilityUsePlayer?.prepareToPlay()
        abilityPointPlayer?.prepareToPlay()
      }
    } else {
      gameOverPlayer = nil
      correctPlayer = nil
      incorrectPlayer = nil
      abilityUsePlayer = nil
      abilityPointPlayer = nil
    }
  }
  
  func playSound(sound: Sound) {
    dispatch_async(dispatch_get_main_queue(), {
      if !self.muted {
        switch sound {
        case .AbilityPoint:
          self.abilityPointPlayer?.play()
        case .AbilityUse:
          self.abilityUsePlayer?.play()
        case .Correct:
          self.correctPlayer?.play()
        case .Incorrect:
          self.incorrectPlayer?.play()
        case .GameOver:
          self.gameOverPlayer?.play()
        }
      }
    })
  }
  
  
}