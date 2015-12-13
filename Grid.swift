//
//  Grid.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

enum GridDirection {
  case Horizontal
  case Vertical
  case Diagonal
}


class Grid: NSObject {
  //Grid Layout Reference Variables
  static let tileCoordinates: Array<GridCoordinates> = [(x:0, y:0), (x:1, y:0), (x:2, y:0), (x:0, y:1), (x:1, y:1), (x:2, y:1), (x:0, y:2), (x:1, y:2), (x:2, y:2)]
  static let operations: Array<Operation> = [.Add, .Divide, .Subtract, .Multiply]
  static let directions: Array<GridDirection> = [.Diagonal, .Horizontal, .Vertical]
}