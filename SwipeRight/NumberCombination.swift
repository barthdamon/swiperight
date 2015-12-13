//
//  NumberCombination.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class NumberCombination : NSObject {
  //TODO: add all winning combination code as an extension to number combination
  var solution = false
  
  var operation = Operation.Add
  var x: Int!
  var b: Int!
  var sum: Int!
  var xPosition: GridCoordinates!
  var bPosition: GridCoordinates!
  var sumPosition = (x: 0, y: 0)
  
  
  var xNumberIndex: Int!
  var bNumberIndex: Int!
  var sumNumberIndex: Int!
  
  var solutionGridPositionIndex: Int!
  var direction: GridDirection?
  
  //probably need:
  var endPoint: GridCoordinates?
  
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
    solutionGridPositionIndex = randoNumber(minX: 0, maxX: UInt32(8))
    sumPosition = Grid.tileCoordinates[solutionGridPositionIndex]
    generateSolutionDirection()
  }
  
  func generateSolutionDirection() {
    let solutionDirection: GridDirection?
    //check the grid for possible directions
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

