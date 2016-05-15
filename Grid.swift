//
//  Grid.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

typealias Coordinates = (x: CGFloat, y: CGFloat)
typealias TileCoordinates = (x: Int, y: Int)

enum GridDirection {
  case Horizontal
  case Vertical
  case Diagonal
}

// difficulty levels (maybe 15?):
// Maybe each round gets a random difficulty addition ???? - some might be easier than others but thats fine.... eveybodies playing the same game in the end
// Make it to the next round perhaps?
// Difficulty types:
// - Extra tiles
// - Extra operations



// Progression 4 picks per round perhaps?:
// Maybe you let them spec as they progress: you choose what to add, eventually it becomes unavailable....
// Tiles: add 2 each time (3)
// Operations: add 1 until full, then add two at once (4)
// Time: Reduce time added and time allowed til end of round (10 sec each) (6)
// Range: Increase range of answers (5)


// Start off with either tile or additions added on.
// When

// Helpers:
// Have 3 helper points per round? - round has 5 questions each perhaps?
// - Remove a tile (1)
// - Remove an operation (2)
// - Highlight section of the answer (3)


// Difficulty Effects (perhaps on a spinner?)
// Time reduction
// Add time reduction
// Another tile (so long as extra tiles are less than 7)
// Number range > (so long as number range is less than 100)

// steady effects
// Add an operation (so long as there are 4 or less operations)
// // Multiple active operations

// Difficulty Progression per round:
//1 : super easy, no extra tiles, add/subtract
//2 : another random operation, random 2 effects.
//3 : another random operation, random 2 effects.
//4 : another random operation, random 2 effects
//5 : multiple active operations, random 2 effects
//4 : random 2 effects forever
// 3 helper points per round, they carry over into the next round


class Grid: NSObject {
  //Grid Layout Reference Variables
  static let tileCoordinates: Array<TileCoordinates> = [(x:0, y:0), (x:1, y:0), (x:2, y:0), (x:0, y:1), (x:1, y:1), (x:2, y:1), (x:0, y:2), (x:1, y:2), (x:2, y:2)]
  static let combinations = [[0,1,2], [0,3,6], [0,4,8], [1,4,7], [2,1,0], [2,5,8], [2,4,6], [3,4,5], [5,4,3], [6,3,0], [6,4,2], [6,7,8], [7,4,1], [8,7,6], [8,4,0], [8,5,2]]
  static let operations: Array<Operation> = [.Add, .Subtract, .Multiply, .Divide]
  static let directions: Array<GridDirection> = [.Diagonal, .Horizontal, .Vertical]
  
  class func indexForTileCoordiate(tile: TileCoordinates) -> Int? {
    return tileCoordinates.indexOf({$0.x == tile.x && $0.y == tile.y})
  }
  
}

