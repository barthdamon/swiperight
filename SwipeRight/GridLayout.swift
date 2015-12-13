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
  
  //actual numbers to be displayed relative to tile coordinates (what gets returned to main vc):
  var numbers = [0,0,0,0,0,0,0,0,0]
  var solutionIndexes: Array<Int>?

  func generateNumberGrid() {
    winningCombination = NumberCombination(solution: true)
    populateGrid()
  }
  
  func populateGrid() {
    setSolutionInGrid()
    injectFillerNumbers()
      //populate the other areas of the grid with the random numbers using recursive function that checks each row and changes numbers if any work together
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
    checkForOtherSolutions()
  }
  
  func checkForOtherSolutions() {
    //make sure none of the other combinations will work
  }
  
  
}

