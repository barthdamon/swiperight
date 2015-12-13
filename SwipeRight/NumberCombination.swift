//
//  NumberCombination.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class NumberCombination : NSObject {
  
  var solution = false
  
  var operation = Operation.Add
  var x: Int!
  var b: Int!
  var sum: Int!
  var direction: GridDirection?
  
  //For Grid Layout
  var xPosition: TileCoordinates? {
    didSet {
      xNumberIndex = Grid.indexForTileCoordiate(xPosition!)
    }
  }
  var bPosition: TileCoordinates? {
    didSet {
      bNumberIndex = Grid.indexForTileCoordiate(bPosition!)
    }
  }
  var sumPosition: TileCoordinates? {
    didSet {
      sumNumberIndex = Grid.indexForTileCoordiate(sumPosition!)
    }
  }
  var solutionGridPositionIndex: Int!
  
  //For Numbers Array
  var xNumberIndex: Int!
  var bNumberIndex: Int!
  var sumNumberIndex: Int!
  
  convenience init(solution: Bool) {
    self.init()
    if solution {
      self.solution = solution
      generateWinningCombination()
    }
  }
  
  func generateWinningCombination() {
    //later set to random operation:
    //    let randomOperationIndex = randoNumber(minX: 0, maxX: 3)
    //    let currentOperation = operations[randomOperationIndex]
    
    let randomSolution = randoNumber(minX:0, maxX:UInt32(100))
    
    switch operation {
    case .Add:
      print("Addition")
      let firstNumber = randoNumber(minX: 0, maxX: UInt32(randomSolution))
      let secondNumber = randomSolution - firstNumber
      self.x = firstNumber
      self.b = secondNumber
      self.sum = randomSolution
    case .Divide:
      print("Division")
      break
    case .Multiply:
      print("Multiplication")
      break
    case .Subtract:
      print("Subtraction")
      break
    }
    
    //set random grid position
    solutionGridPositionIndex = generateSolutionGridPositionIndex()
    sumPosition = Grid.tileCoordinates[solutionGridPositionIndex]
    generateSolutionDirection()
    generateXBPositions()
  }
  
  func generateSolutionGridPositionIndex() -> Int {
    var index: Int!
    //Can't have the index for the solution be the middle of the grid
    func generateRand() {
      index = randoNumber(minX: 0, maxX: UInt32(8))
      if index == 4 {
        generateRand()
      }
    }
    generateRand()
    return index
  }
  
  func generateSolutionDirection() {
    let solutionDirection: GridDirection?
    //check the grid for possible directions
    if let sumPosition = sumPosition {
      switch sumPosition {
        //only vertical
      case (x: 1, y: 0), (x: 1, y: 2):
        solutionDirection = .Vertical
        //only horizontal
      case (x: 0, y: 1), (x: 2, y: 1):
        solutionDirection = .Horizontal
      default:
        let randomDirectionIndex = randoNumber(minX: 0, maxX: 2)
        solutionDirection = Grid.directions[randomDirectionIndex]
      }
      direction = solutionDirection
    }
  }
  
  func generateXBPositions() {
    //needs to go the proper direction if the sum is on an edge grid spot
    if let direction = direction, sumPosition = sumPosition {
      switch direction {
      case .Horizontal:
        bPosition = (x: 1, y: sumPosition.y)
        if sumPosition.x == 2 {
          xPosition = (x: 0, y: sumPosition.y)
        } else {
          xPosition = (x: 2, y: sumPosition.y)
        }
      case .Vertical:
        bPosition = (x: sumPosition.x, y: 1)
        if sumPosition.y == 2 {
          xPosition = (x: sumPosition.x, y: 0)
        } else {
          xPosition = (x: sumPosition.x, y: 2)
        }
      case .Diagonal:
        xPosition = (x: 1, y: 1)
        switch sumPosition {
        case (x: 2, y: 2):
          bPosition = (x: 0, y: 0)
          break
        case (x: 0, y: 2):
          bPosition = (x: 2, y: 0)
          break
        case (x: 2, y: 0):
          bPosition = (x: 0, y: 2)
          break
        case (x: 0, y: 0):
          bPosition = (x: 2, y: 2)
          break
        default:
          break
        }
      }
    }
  }
  
}

