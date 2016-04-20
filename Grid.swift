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

