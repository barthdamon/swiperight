//
//  GridLayout.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

//need to generate position and xb positions fist, then select the random numbers to populate them after!
//First need to put code in numbercombination that makes sure not to override any points in solutions. it can use the same, but not override...
//basically do this by passing in numbers to NumberCombination init(), that way it can tell what is already set (which will only ever be other solutions). Just when generating random numbers check if the index of that spot already exists, and if it does adjust the random number generation accordingly to match the operation
//then need to have solutionIndexes array just be bigger, and generate several numberCombinations depending on difficulty selected

enum Operation: String {
  case Divide = "division"
  case Subtract = "subtraction"
  case Add = "addition"
  case Multiply = "multiplication"
  
  var color: UIColor {
    switch self {
    case Divide:
      return UIColor(red:0.70, green:0.55, blue:0.75, alpha:1.00)
    case Subtract:
      return UIColor(red:0.51, green:0.53, blue:0.76, alpha:1.00)
    case Add:
      return UIColor(red:0.99, green:0.76, blue:0.57, alpha:1.00)
    case Multiply:
      return UIColor(red:0.96, green:0.91, blue:0.45, alpha:1.00)
    }
  }
  
  var flashName: String {
    switch self {
    case Divide:
      return "DIVIDE"
    case Subtract:
      return "SUBTRACT"
    case Add:
      return "ADD"
    case Multiply:
      return "MULTIPLY"
    }
  }
  
  var image: UIImage? {
    switch self {
    case Divide:
      return ThemeHelper.defaultHelper.divideImage
    case Subtract:
      return ThemeHelper.defaultHelper.divideImage
    case Add:
      return ThemeHelper.defaultHelper.addImage
    case Multiply:
      return ThemeHelper.defaultHelper.multiplyImage
    }
  }
  
  var flashImage: UIImage? {
    switch self {
    case Divide:
      return ThemeHelper.defaultHelper.divideFlashImage
    case Subtract:
      return ThemeHelper.defaultHelper.subtractFlashImage
    case Add:
      return ThemeHelper.defaultHelper.addFlashImage
    case Multiply:
      return ThemeHelper.defaultHelper.multiplyFlashImage
    }
  }
  
  
  var inactiveImage: UIImage? {
    switch self {
    case Divide:
      return ThemeHelper.defaultHelper.divideImage
    case Subtract:
      return ThemeHelper.defaultHelper.subtractImage
    case Add:
      return ThemeHelper.defaultHelper.addImage
    case Multiply:
      return ThemeHelper.defaultHelper.multiplyImage
    }
  }
  
}

class GridNumberLayout: NSObject {
  
  var winningCombination: NumberCombination?
  var operations: Array<Operation> = ProgressionManager.sharedManager.getCurrentOperations()
//  012
//  345
//  678
  
  //NOTE: ALL TILES START AT 0 INSTEAD OF ONE DONT GET CONFUSED
  //actual numbers to be displayed relative to tile coordinates (what gets returned to main vc):
  var numbers = [-1,-1,-1,-1,-1,-1,-1,-1,-1]
  var populatedTiles: Array<Int> = []

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
  
  func resetPopulatedTiles() {
    if let indexes = solutionIndexes {
      populatedTiles = indexes
    }
  }
  
  func injectFillerNumbers() {
    resetPopulatedTiles()
    calculateTileFillerIndexes()
    fillFillers(populatedTiles)
  }
  
  func fillFillers(populated: Array<Int>) {
    if let solution = winningCombination {
      let tilePopulation = populated.filter({$0 != solution.xNumberIndex && $0 != solution.bNumberIndex && $0 != solution.sumNumberIndex})
      for (i, _) in numbers.enumerate() {
        if tilePopulation.contains(i) {
          // need to check other populated tiles
          let numberRequired = ProgressionManager.sharedManager.numberOfExtraTiles
          
          numbers[i] = Int.random(0...ProgressionManager.sharedManager.range)
        }
      }
      checkForOtherSolutions(populated)
    }
  }
  
  
  func calculateTileFillerIndexes() {
    let numberOfExtraTiles = ProgressionManager.sharedManager.numberOfExtraTiles
    var requiredConnections = 1
    if numberOfExtraTiles == 6 {
      requiredConnections = 16
    } else {
      requiredConnections = numberOfExtraTiles * 2
    }
    guard numberOfExtraTiles > 0 else { return }
    var emptyTiles: Array<Int> = []
    for tileIndex in 0...8 {
      if !populatedTiles.contains(tileIndex) {
        emptyTiles.append(tileIndex)
      }
    }
    // fill up the tiles
    var currentTile = 1
    repeat {
      let numberEmpty = emptyTiles.count - 1
      if emptyTiles.count > 0 {
        let randTileIndex = Int.random(0...numberEmpty)
        populatedTiles.append(emptyTiles[randTileIndex])
        emptyTiles.removeAtIndex(randTileIndex)
      }
      currentTile += 1
    } while currentTile <= numberOfExtraTiles
    
    if numberOfConnections(populatedTiles) != requiredConnections {
      print("Need more connections in filler...")
      resetPopulatedTiles()
      calculateTileFillerIndexes()
    }
  }
  
  func numberOfConnections(populatedTiles: Array<Int>) -> Int {
    var connectionsInPopulated = 0
    for combination in Grid.combinations {
      var contained = true
      for index in combination {
        if !populatedTiles.contains(index) {
          contained = false
        }
      }
      if contained { connectionsInPopulated += 1 }
    }
    return connectionsInPopulated
  }
  
  func checkForOtherSolutions(populated: Array<Int>) {
    if let solution = winningCombination {
      for possible in Grid.combinations {
        let posX = numbers[possible[0]]
        let posB = numbers[possible[1]]
        let posSum = numbers[possible[2]]
        if posX != -1 && posB != -1 && posSum != -1 {
          if !((possible[0] == solution.xNumberIndex && possible[1] == solution.bNumberIndex && possible[2] == solution.sumNumberIndex) || (possible[0] == solution.sumNumberIndex && possible[1] == solution.bNumberIndex && possible[2] == solution.xNumberIndex)) {
            if !fillerClearsOperations(posX, b: posB, sum: posSum) {
              print("Extra solution found: \(posX) \(posB) \(posSum), regenerating filler...")
              fillFillers(populated)
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

