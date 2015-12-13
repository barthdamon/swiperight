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
  static let operations: Array<Operation> = [.Add, .Divide, .Subtract, .Multiply]
  static let directions: Array<GridDirection> = [.Diagonal, .Horizontal, .Vertical]
  
  class func indexForTileCoordiate(tile: TileCoordinates) -> Int? {
    return tileCoordinates.indexOf({$0.x == tile.x && $0.y == tile.y})
  }
}