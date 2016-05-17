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
    if let indexes = solutionIndexes {
      var omitted = indexes
      let omittedTiles = generateOmittedTiles()
      omittedTiles.forEach({omitted.append($0)})
      
      for (i, _) in numbers.enumerate() {
        if !omitted.contains(i) {
          numbers[i] = Int.random(0...ProgressionManager.sharedManager.range)
        }
      }
      checkForOtherSolutions()
    }
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
  
  func generateOmittedTiles() -> Array<Int> {
    var omittedTiles: Array<Int> = []
    var tiles: Array<Int> = []
    // I guess first find the ones that aren't omitted then take those out and the rest are omitted????
    let numberOfTiles = ProgressionManager.sharedManager.numberOfTiles
    if let combination = winningCombination, direction = combination.direction {
      if numberOfTiles == 5 {
        
        
        switch direction {
        case .Diagonal:
          let randDirection = Int.random(0...1)
          if combination.xNumberIndex == 0 {
            if randDirection == 0 {
              tiles.append(1)
              tiles.append(2)
            } else {
              tiles.append(3)
              tiles.append(6)
            }
          } else {
            if randDirection == 0 {
              tiles.append(7)
              tiles.append(6)
            } else {
              tiles.append(5)
              tiles.append(2)
            }
          }
          break
        case .Vertical:
          // in the middle
          if combination.xNumberIndex == 1 || combination.xNumberIndex == 7 {
            let randDirection = Int.random(0...3)
            if randDirection == 0 {
              tiles.append(0)
              tiles.append(8)
            } else if randDirection == 1 {
              tiles.append(2)
              tiles.append(6)
            } else if randDirection == 2 {
              tiles.append(0)
              tiles.append(2)
            } else if randDirection == 3 {
              tiles.append(6)
              tiles.append(8)
            }
            // on the right
          } else if combination.xNumberIndex == 2 || combination.xNumberIndex == 5 || combination.xNumberIndex == 8 {
            let randDirection = Int.random(0...2)
            if randDirection == 0 {
              tiles.append(combination.xNumberIndex - 1)
              tiles.append(combination.xNumberIndex - 2)
            } else if randDirection == 2 {
              tiles.append(combination.bNumberIndex - 1)
              tiles.append(combination.bNumberIndex - 2)
            } else {
              tiles.append(combination.sumNumberIndex - 1)
              tiles.append(combination.sumNumberIndex - 2)
            }
          } else {
            // on the left
            let randDirection = Int.random(0...2)
            if randDirection == 0 {
              tiles.append(combination.xNumberIndex + 1)
              tiles.append(combination.xNumberIndex + 2)
            } else if randDirection == 2 {
              tiles.append(combination.bNumberIndex + 1)
              tiles.append(combination.bNumberIndex + 2)
            } else {
              tiles.append(combination.sumNumberIndex + 1)
              tiles.append(combination.sumNumberIndex + 2)
            }
          }
        case .Horizontal:
          // in the middle
          if combination.xNumberIndex == 3 || combination.xNumberIndex == 5 {
            let horMidRandDirection = Int.random(0...4)
            switch horMidRandDirection {
            case 0:
              tiles.append(0)
              tiles.append(8)
            case 1:
              tiles.append(2)
              tiles.append(6)
            case 2:
              tiles.append(0)
              tiles.append(6)
            case 3:
              tiles.append(1)
              tiles.append(7)
            case 4:
              tiles.append(2)
              tiles.append(8)
            default:
              break
            }
            // on the bottom
          } else if combination.xNumberIndex == 6 || combination.xNumberIndex == 7 || combination.xNumberIndex == 8 {
            let randDirection = Int.random(0...2)
            if randDirection == 0 {
              tiles.append(combination.xNumberIndex - 3)
              tiles.append(combination.xNumberIndex - 6)
            } else if randDirection == 1 {
              tiles.append(combination.bNumberIndex - 3)
              tiles.append(combination.bNumberIndex - 6)
            } else {
              tiles.append(combination.sumNumberIndex - 3)
              tiles.append(combination.sumNumberIndex - 6)
            }
          } else {
            // on the top
            let randDirection = Int.random(0...2)
            if randDirection == 0 {
              tiles.append(combination.xNumberIndex + 3)
              tiles.append(combination.xNumberIndex + 6)
            } else if randDirection == 1 {
              tiles.append(combination.bNumberIndex + 3)
              tiles.append(combination.bNumberIndex + 6)
            } else {
              tiles.append(combination.sumNumberIndex + 3)
              tiles.append(combination.sumNumberIndex + 6)
            }
          }
        }
        
        
      } else if numberOfTiles == 7 {
        switch direction {
        case .Diagonal:
          if combination.xNumberIndex == 0 {
            
            // blank number tiles either go on
          } else {
            
          }
          break
        case .Vertical:
          break
        case .Horizontal:
          break
        }
      }
    }
    
    // Add any indexes that aren't used to omitted tiles
    for gridIndex in 0...8 {
      if !tiles.contains(gridIndex) {
        omittedTiles.append(gridIndex)
      }
    }
    return omittedTiles
  }

  
}

