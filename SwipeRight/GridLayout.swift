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
    //TODO: Refactor the shit out of this so that it is smart enough to place tiles so that they confuse player, and so that it checks for no other existing solutions
      resetPopulatedTiles()
      calculateTileFillerIndexes()
    
      fillFillers(populatedTiles)
  }
  
  func fillFillers(populated: Array<Int>) {
    if let solution = winningCombination {
      let tilePopulation = populated.filter({$0 != solution.xNumberIndex && $0 != solution.bNumberIndex && $0 != solution.sumNumberIndex})
      for (i, _) in numbers.enumerate() {
        if tilePopulation.contains(i) {
          numbers[i] = Int.random(0...ProgressionManager.sharedManager.range)
        }
      }
      checkForOtherSolutions(populated)
    }
  }
  
  func calculateTileFillerIndexes() {
    // is this number of tiles right? Seems like the set isn't getting in as it should
    let setsOfExtraTiles = ProgressionManager.sharedManager.setsOfExtraTiles
    var requiredConnections = 1
    switch setsOfExtraTiles {
    case 1:
      requiredConnections = 2
    case 2:
      requiredConnections = 4
    case 3:
      requiredConnections = 8
    default:
      break
    }
    var emptyTiles: Array<Int> = []
    for tileIndex in 0...8 {
      if !populatedTiles.contains(tileIndex) {
        emptyTiles.append(tileIndex)
      }
    }
    let numberOfExtraTiles = setsOfExtraTiles * 2
    if numberOfExtraTiles > 0 {
      for _ in 0...numberOfExtraTiles - 1 {
        let numberEmpty = emptyTiles.count - 1
        let randTileIndex = Int.random(0...numberEmpty)
        populatedTiles.append(emptyTiles[randTileIndex])
      }
    }
    guard numberOfConnections(populatedTiles) != requiredConnections else {
      print("Need more connections in filler...")
      resetPopulatedTiles()
      calculateTileFillerIndexes()
      return
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

