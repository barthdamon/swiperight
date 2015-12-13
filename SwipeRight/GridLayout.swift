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

  func generateNumberGrid() {
    winningCombination = NumberCombination(solution: true)
    populateGrid()
  }
  
  func populateGrid() {
    //should only need three numberCombinations in this array
    //    var numbers : Array<NumberCombination> = [solution]
      setSolutionInGrid()
      
      //populate the other areas of the grid with the random numbers using recursive function that checks each row and changes numbers if any work together
      
      //TODO: set the gridNumbers to the solution
  }
  
  
  //randomization:
  // [(x:0, y:0), (x:1, y:0), (x:2, y:0), (x:0, y:1), (x:1, y:1), (x:2, y:1), (x:0, y:2), (x:1, y:2), (x:2, y:2)]
  
  func setSolutionInGrid() {
    if let winningCombination = winningCombination {
      numbers[winningCombination.solutionGridPositionIndex] = winningCombination.sum
      winningCombination.sumNumberIndex = numbers[winningCombination.solutionGridPositionIndex]
      
      numbers[generateBPosition()] = winningCombination.b
      
      if let direction = winningCombination.direction {
        switch direction {
        case .Horizontal:
          break
        case .Vertical:
          break
        case .Diagonal:
          break
        }
      }
    }
  }
  
  func generateBPosition() -> Int {
    //needs to go the proper direction if the sum is on an edge grid spot
    
    return 1
  }

}

