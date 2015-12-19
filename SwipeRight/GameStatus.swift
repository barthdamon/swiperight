//
//  GameStatus.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/17/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

enum GameMode: Int {
  case Puzzle = 1
  case Normal = 2
  case Speed = 3
}

private var _status = GameStatus()


class GameStatus: NSObject {
  
  class var status: GameStatus {
    return _status
  }
  
  var gameActive = false
  var selectedMode: GameMode = .Normal
  
}