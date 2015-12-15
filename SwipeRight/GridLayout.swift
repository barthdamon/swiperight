//
//  GridLayout.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class GridNumberLayout: NSObject {
  
  var winningCombination: NumberCombination?
  
  //NOTE: ALL TILES START AT 0 INSTEAD OF ONE DONT GET CONFUSED
  //actual numbers to be displayed relative to tile coordinates (what gets returned to main vc):
  var numbers = [0,0,0,0,0,0,0,0,0]
  //some of these only have to be once for multiplication and addition (less math, but thats an optimization)
  var solutionIndexes: Array<Int>?
  
  override init() {
    super.init()
    generateNumberGrid()
  }

  func generateNumberGrid() {
    winningCombination = NumberCombination(solution: true)
    populateGrid()
  }
  
  func populateGrid() {
    setSolutionInGrid()
    injectFillerNumbers()
  }
  
  func setSolutionInGrid() {
    if let solution = winningCombination {
      numbers[solution.xNumberIndex] = solution.x
      numbers[solution.bNumberIndex] = solution.b
      numbers[solution.sumNumberIndex] = solution.sum
      solutionIndexes = [solution.xNumberIndex, solution.bNumberIndex, solution.sumNumberIndex]
    }
  }
  
  func injectFillerNumbers() {
    if let omitted = solutionIndexes {
      for var i = 0; i < numbers.count; i++ {
        if !omitted.contains(i) {
          numbers[i] = randoNumber(minX: 0, maxX: UInt32(100))
        }
      }
    }
//    checkForOtherSolutions()
  }
  
//  func checkForOtherSolutions() {
//    
//    var valid = true
//    //make sure none of the other combinations will work. HAS TO GO BOTH WAYS FOR THE SOLUTION THOUGH. Its crashing cause infinitely looping through it injecting
//    for combo in Grid.combinations {
//      if !checkIfSolution(combo) {
//        let numbersOne = numbers[combo[0]]
//        let numbersTwo = numbers[combo[1]]
//        let numbersThree = numbers[combo[2]]
//        
//        if numbersOne + numbersTwo == numbersThree {
//          valid = false
//        } else if numbersOne - numbersTwo == numbersThree {
//          valid = false
//        } else if numbersOne * numbersTwo == numbersThree {
//          valid = false
//        } else if numbersOne != 0 && numbersTwo != 0 {
//          if numbersOne / numbersTwo == numbersThree {
//            valid = false
//          }
//        }
//      }
//    }
//    
//    if !valid {
//      valid = true
//      injectFillerNumbers()
//    }
//  }
//  
//  func checkIfSolution(combo: Array<Int>) -> Bool {
//    if let solutionIndexes = solutionIndexes {
//      if combo[0] == solutionIndexes[0] && combo[1] == solutionIndexes[1] && combo[2] == solutionIndexes[2] {
//        return true
//      } else {
//        return false
//      }
//    } else {
//      return false
//    }
//  }
  
  
}

