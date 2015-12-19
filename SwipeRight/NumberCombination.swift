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
  var numbers: Array<Int>!
  
  //to avoid overrides
  var previousWinners: Array<NumberCombination>!
  var conflictingCombinations: Array<Array<Int>> = []

  
  convenience init(solution: Bool, layout: GridNumberLayout) {
    self.init()
    self.numbers = layout.numbers
    self.previousWinners = layout.winningCombinations
    if solution {
      self.solution = solution
      generateWinningCombination()
    }
  }
  
  func generateWinningCombination() {
    //later set to random operation:
    //    let randomOperationIndex = randoNumber(minX: 0, maxX: 3)
    //    let currentOperation = operations[randomOperationIndex]
    //set random grid position
    solutionGridPositionIndex = generateSolutionGridPositionIndex()
    sumPosition = Grid.tileCoordinates[solutionGridPositionIndex]
    generateSolutionDirection()
    generateXBPositions()
    setNumberValues()

    //check for complete override, then redo if it exists
    for winner in previousWinners {
      let first = winner.conflictingCombinations[0]
      let second = winner.conflictingCombinations[1]
      let ourFirst = self.conflictingCombinations[0]
      let ourSecond = self.conflictingCombinations[1]
      
      if (first[0] == ourFirst[0] && first[1] == ourFirst[1] && first[2] == ourFirst[2]) || (second[0] == ourSecond[0] && second[1] == ourSecond[1] && second[2] == ourSecond[2]) || (first[0] == ourFirst[2] && first[1] == ourFirst[1] && first[2] == ourFirst[0]) || (second[0] == ourSecond[2] && second[1] == ourSecond[1] && second[2] == ourSecond[0]) {
        //need to make a whole new one
        generateWinningCombination()
      }
    }
    
  }
  
  func setNumberValues() {
    //Might have the case where another solution completely overrides this one, oh well makes it interesting, they dont need to know the actual mechanics. Theres a chance of three, suck it.
    //now just need to make sure you aren't overriding anything here
    var randomSolution = 0
    if notSet(sumNumberIndex) {
      randomSolution = randoNumber(minX:1, maxX:UInt32(100))
    } else {
      randomSolution = numbers[sumNumberIndex]
    }
    
    switch operation {
    case .Add:
      var firstNumber = 0
      var secondNumber = 0
      var firstNumberNeedsSetting = false
      print("Addition")
      
      //first number
      if notSet(xNumberIndex) {
        //first need to check if the third number is set and set this based on that in case that one can't change
        if notSet(bNumberIndex) {
          firstNumber = randoNumber(minX: 1, maxX: UInt32(randomSolution))
        } else {
          firstNumberNeedsSetting = true
        }
      } else {
        firstNumber = numbers[xNumberIndex]
      }
      
      //second number
      if notSet(bNumberIndex) {
        secondNumber = randomSolution - firstNumber
      } else {
        secondNumber = numbers[bNumberIndex]
        if firstNumberNeedsSetting {
         firstNumber = randomSolution - secondNumber
        }
      }
      
      self.x = firstNumber
      self.b = secondNumber
      self.sum = randomSolution
      print("FIRSTNUMBER: \(firstNumber)")
      print("SECONDNUMBER: \(secondNumber)")
      print("THIRDNUMBER: \(randomSolution)")
      print("SUM INDEX: \(sumNumberIndex)")
      print("PREVIOUS: \(self.previousWinners.count)")
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
    //set conflict combinations
    self.conflictingCombinations = [[xNumberIndex, bNumberIndex, sumNumberIndex],[sumNumberIndex, bNumberIndex, xNumberIndex]]
  }
  
  //helper for checking if number index can't be overridden
  func notSet(index: Int) -> Bool {
    if numbers[index] != -1 {
      return false
    } else {
      return true
    }
  }
}

