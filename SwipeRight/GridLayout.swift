//
//  GridLayout.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

//need to generate position and xb positions fist, then select the random numbers to populate them after!
//First need to put code in numbercombination that makes sure not to override any points in solutions. it can use the same, but not override...
//basically do this by passing in numbers to NumberCombination init(), that way it can tell what is already set (which will only ever be other solutions). Just when generating random numbers check if the index of that spot already exists, and if it does adjust the random number generation accordingly to match the operation
//then need to have solutionIndexes array just be bigger, and generate several numberCombinations depending on difficulty selected

class GridNumberLayout: NSObject {
  
  var winningCombinations: Array<NumberCombination> = []
  var operations: Array<Operation>!
  
  //NOTE: ALL TILES START AT 0 INSTEAD OF ONE DONT GET CONFUSED
  //actual numbers to be displayed relative to tile coordinates (what gets returned to main vc):
  var numbers = [-1,-1,-1,-1,-1,-1,-1,-1,-1]
  //some of these only have to be once for multiplication and addition (less math, but thats an optimization)
  var solutionIndexes: Array<Int>?
  
  override init() {
    super.init()
    randomizeOperation()
    generateNumberGrid()
  }
  
  func randomizeOperation() {
    //later set to random operation:
    operations = nil
    operations = Array()
//    let randomPlusMinusIndex = 1
    let randomPlusMinusIndex = randoNumber(0, max: 1)
    operations.append(Grid.operations[2])
//    let randomTwo = 3
    let randomTwo = randoNumber(2, max: 3)
    operations.append(Grid.operations[3])
    
  }

  func generateNumberGrid() {
    for var i = 0; i < GameStatus.status.selectedMode.rawValue; i++ {
      winningCombinations.append(NumberCombination(solution: true, layout: self))
      setSolutionInGrid(i)
    }
//    injectFillerNumbers()
  }
  
  func setSolutionInGrid(index: Int) {
    let solution = winningCombinations[index]
    numbers[solution.xNumberIndex] = solution.x
    numbers[solution.bNumberIndex] = solution.b
    numbers[solution.sumNumberIndex] = solution.sum
    solutionIndexes = [solution.xNumberIndex, solution.bNumberIndex, solution.sumNumberIndex]
    print("Winning indexes: \(solution.xNumberIndex), \(solution.bNumberIndex), \(solution.sumNumberIndex)")
  }
  
  func injectFillerNumbers() {
    if let omitted = solutionIndexes {
      for var i = 0; i < numbers.count; i++ {
        if !omitted.contains(i) {
          numbers[i] = randoNumber(nil, max: 50)
        }
      }
    }
//    checkForOtherSolutions() (refer to github history for this code)
  }
  
}

