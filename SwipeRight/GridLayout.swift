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

enum Operation {
  case Divide
  case Subtract
  case Add
  case Multiply
}

class GridNumberLayout: NSObject {
  
  var winningCombination: NumberCombination?
  var operations: Array<Operation> = ProgressionManager.sharedManager.randomActiveOperations()
//  012
//  345
//  678
  
  //NOTE: ALL TILES START AT 0 INSTEAD OF ONE DONT GET CONFUSED
  //actual numbers to be displayed relative to tile coordinates (what gets returned to main vc):
  var numbers = [-1,-1,-1,-1,-1,-1,-1,-1,-1]

  //some of these only have to be once for multiplication and addition (less math, but thats an optimization)
  var solutionIndexes: Array<Int>?
  
  override init() {
    super.init()
    generateNumberGrid()
  }

  func generateNumberGrid() {
    winningCombination = NumberCombination(solution: true, layout: self)
    setSolutionInGrid()
    injectFillerNumbers()
  }
  
  func setSolutionInGrid() {
    if let solution = winningCombination {
      numbers[solution.xNumberIndex] = solution.x
      numbers[solution.bNumberIndex] = solution.b
      numbers[solution.sumNumberIndex] = solution.sum
      solutionIndexes = [solution.xNumberIndex, solution.bNumberIndex, solution.sumNumberIndex]
      print("Winning indexes: \(solution.xNumberIndex), \(solution.bNumberIndex), \(solution.sumNumberIndex)")
    }
  }
  
  func injectFillerNumbers() {
    //TODO: Refactor the shit out of this so that it is smart enough to place tiles so that they confuse player, and so that it checks for no other existing solutions
//    if let combination = winningCombination {
//      switch winningCombination {
//        
//      }
//    }

    if let omitted = solutionIndexes {
      for (i, _) in numbers.enumerate() {
        if !omitted.contains(i) {
          numbers[i] = Int.random(0...ProgressionManager.sharedManager.range)
        }
      }
    }
    checkForOtherSolutions()
  }
  
  func checkForOtherSolutions() {
    if let solution = winningCombination {
      for possible in Grid.combinations {
        let posX = numbers[possible[0]]
        let posB = numbers[possible[1]]
        let posSum = numbers[possible[2]]
        if posX != -1 && posB != -1 && posSum != -1 {
          if !((possible[0] == solution.xNumberIndex && possible[1] == solution.bNumberIndex && possible[2] == solution.sumNumberIndex) || (possible[0] == solution.sumNumberIndex && possible[1] == solution.bNumberIndex && possible[2] == solution.xNumberIndex)) {
            if !fillerClearsOperations(posX, b: posB, sum: posSum) {
              print("Extra solution found: \(posX) \(posB) \(posSum), regenerating filler...")
              injectFillerNumbers()
              break
            }
          }
        }
      }
    }
  }
  
  func fillerClearsOperations(x: Int, b: Int, sum: Int) -> Bool {
    if b == 0 {
      if x + b == sum || x * b == sum || x - b == sum {
        return false
      }
    } else {
      if x + b == sum || sum / b == x || x * b == sum || x - b == sum {
        return false
      }
    }
    return true
  }

  
}

