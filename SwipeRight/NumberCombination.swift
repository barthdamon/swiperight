//
//  NumberCombination.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

//BUG: WHEN GOING HORIZONTALLY OR VERTICALLY ACCROSS THE MIDDLE THE NUMBERS ON BOTH ENDS ARE THE SAME

class NumberCombination : NSObject {
  
  var solution = false
  
  var operation: Operation = .Add
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
  var numbers: Array<Int>!
  
  convenience init(solution: Bool, layout: GridNumberLayout) {
    self.init()
    self.numbers = layout.numbers
    self.operation = layout.operations[0]
    if solution {
      self.solution = solution
      generateWinningCombination()
    }
  }
  
  func generateWinningCombination() {
    //set random grid position
    solutionGridPositionIndex = generateSolutionGridPositionIndex()
    sumPosition = Grid.tileCoordinates[solutionGridPositionIndex]
    generateSolutionDirection()
    generateXBPositions()
    setNumberValues()


    
    print("<<<<<<<<<<<")
    print("OPERATION: \(operation)")
    print("x: \(self.x)")
    print("b: \(self.b)")
    print("sum: \(self.sum)")
    print("SUM INDEX: \(sumNumberIndex)")
    print(">>>>>>>>>>>")
  }
  
  func generateSolutionGridPositionIndex() -> Int {
    var index: Int!
    //Can't have the index for the solution be the middle of the grid
    func generateRand() {
      index = Int.random(0...8)
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
        let randomDirectionIndex = Int.random(0...2)
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
        bPosition = (x: 1, y: 1)
        switch sumPosition {
        case (x: 2, y: 2):
          xPosition = (x: 0, y: 0)
          break
        case (x: 0, y: 2):
          xPosition = (x: 2, y: 0)
          break
        case (x: 2, y: 0):
          xPosition = (x: 0, y: 2)
          break
        case (x: 0, y: 0):
          xPosition = (x: 2, y: 2)
          break
        default:
          break
        }
      }
    }
  }
  
  //helper for checking if number index can't be overridden
  func notSet(index: Int) -> Bool {
    if numbers[index] != -1 {
      return false
    } else {
      return true
    }
  }

  
  func setNumberValues() {
    var solution = 0
    var firstNumber = 0
    var secondNumber = 0
    let combo = MultipleHelper.defaultHelper.combinationWithinRange()
    
    switch operation {
    case .Add:
      solution = Int.random(2...ProgressionManager.sharedManager.range)
      firstNumber = Int.random(1...solution - 1)
      secondNumber = completeOperation(solution, first: firstNumber, second: nil, operation: operation)
    case .Subtract:
      solution = Int.random(2...ProgressionManager.sharedManager.range - 2)
      firstNumber = Int.random(solution...ProgressionManager.sharedManager.range)
      secondNumber = completeOperation(solution, first: firstNumber, second: nil, operation: operation)
    case .Multiply:
      solution = combo.sum
      secondNumber = combo.b
      firstNumber = combo.x
    case .Divide:
      firstNumber = combo.sum
      secondNumber = combo.b
      solution = combo.x
    }
    
    if (solution == 0 || secondNumber == 0 || firstNumber == 0) || (ProgressionManager.sharedManager.multipleOperationsDisplayActive && checkForMultipleActive(firstNumber, b: secondNumber, sum: solution)) {
      setNumberValues()
    } else {
      self.x = firstNumber
      self.b = secondNumber
      self.sum = solution
    }
  }
  
  func checkForMultipleActive(x: Int, b: Int, sum: Int) -> Bool {
    switch operation {
    case .Add:
      if sum / b == x || x * b == sum || x - b == sum {
        return true
      }
    case .Subtract:
      if x + b == sum || sum / b == x || x * b == sum {
        return true
      }
    case .Multiply:
      if x + b == sum || sum / b == x || x - b == sum {
        return true
      }
    case .Divide:
      if x + b == sum || x * b == sum || x - b == sum {
        return true
      }
    }
    return false
  }

}

