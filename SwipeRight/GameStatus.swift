//
//  GameStatus.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/17/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

enum GameMode {
  case Tutorial
  case Standard
}

private var _status = GameStatus()

class GameStatus: NSObject {
  
  class var status: GameStatus {
    return _status
  }
  
  var gameActive = false
  var gameMode: GameMode = .Standard
  var tutorialStage = 0
  var inMenu: Bool = true
  
  var time: Int = 0
  var score: Int = 0
  var gameDuration: Int {
    return ProgressionManager.sharedManager.standardRoundDuration
  }
  var timer: NSTimer?
  var gc_leaderboard_id: String {
    get {
      if let first = UserDefaultsManager.sharedManager.getObjectForKey("gc_leaderboard_id") as? String {
        return first
      } else {
        return "sw_all_time_leaderboard"
      }
    }
    set (newValue) {
      UserDefaultsManager.sharedManager.setValueAtKey("gc_leaderboard_id", value: newValue)
    }
  }
  
  var gc_enabled: Bool {
    get {
      if let first = UserDefaultsManager.sharedManager.getObjectForKey("gc_enabled") as? Bool {
        return first
      } else {
        return true
      }
    }
    set (newValue) {
      UserDefaultsManager.sharedManager.setValueAtKey("gc_enabled", value: newValue)
    }
  }
  
  var gc_login_view_controller: UIViewController?
  
//  var highlightTileTimer: NSTimer?
//  var tilesToHighlight: Array<TileView> = []
//  var inTutorialHighlightMode: Bool = false
//  var tutorialTimeForHelper: Bool = false
//  var backFromTutorialHelper: Bool = false
//  var solvedOneOnFive: Bool = false
//  var pausingForEffect: Bool = false
}

/*
 Tutorial Stages
 0 - TEXT: "Find the three tiles adjacent or diagonal to each other that complete a mathematical equation."
 1 - TEXT: "Swipe the tiles from the start of the equation to the end to score a point."
 2 - GAMEBOARD: Show glowing tiles from start to end when they press start end glows and if they miss start glows again. Send back to text after correct.
 3 - TEXT/ACTION: - blinking timer - "Every equation you swipe corrrectly adds five seconds to the countdown timer."
 4 - TEXT/ACTION: - blinking operations - "There is only one active equation. Active operations indicate the operation of the equation."
 5 - TEXT - "At higher levels two operations become active to trick you, but there is still only one equation."
 6 - GAMEBOARD - Two operations active with only 10 highest range. Let them swipe then send back to text
 7 - TEXT/ACTION - Flashing bonus point texts - For every three equations of an operation you swipe right in a row you get a bonus point.
 8 - GAMEBOARD/ACTION - Flashing helper button, gameView inactive - They have 1 helper point and there is almost all tiles with range up to 30
 9 - HELPER POINT CONTROLLER - Flashing hide a tile button, others inactive, question mark allowed - be careful here...
 10 - GAMEBOARD - Tile helper used, wait for them to swipe, then send to text
 11 - TEXT - Ready for the real thing? yes + no buttons -> both start the game.
 12 - GAMEBOARD - begin Countdown, overlay a label -> yes? "Wohoo! you got this!", no? "Don't worry, you got this!"
*/


