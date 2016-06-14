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
}

/*
 Tutorial Stages
 0 - TEXT: "Find the three tiles adjacent or diagonal to each other that complete a mathematical equation."
 1 - TEXT: "Swipe the tiles from the start of the equation to the end to score a point."
 2 - GAMEBOARD: Show glowing tiles from start to end when they press start end glows and if they miss start glows again. Send back to text after correct.
 3 - TEXT/ACTION: - blinking timer - "Every equation you swipe right adds five seconds to the countdown timer."
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


