//
//  ProgressionManager.swift
//  SwipeRight
//
//  Created by Matthew Barth on 5/15/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


// What to let people buy.... Art? Maybe they can buy their own tiles or boards. Then you can play with your friends or on an online tournament on your own boards.
// Make your own mini tournement socket system.... Or you can challenge individuals directly
// In multiplayer you then pick for your opponent!

/* Maybe you let them spec as they progress: you choose what to add, eventually it becomes unavailable....
// Only get two options each time...... AND ITS RANDOM... Mix the two - custom pick they choose to lose with
// Show the difficult adder, and the # left of that adder
// Tiles: add 2 each time (3)
// Operations: add 1 until full, then add two at once (4)
// Time: 
   - Round time: (20 sec each) (3)
   - Boost time: (5 sec each) (2)
*/
// Range: Increase range of answers (5) check
// Helper points (get 3 each round, let them stack)


class ProgressionManager: NSObject {
  
  static var sharedManager = ProgressionManager()
  
  // MARK: General
  let roundLength: Int = 4
  
  // MARK: Operations
  // get a random one for this, but then get random other when progression at that level for the UI
  var activeOperations: Array<Operation> = [.Add]
  var multipleOperationsDisplayActive: Bool = false
  func addRandomOperation() {
    let operationsLeft = Grid.operations.filter { (operation) -> Bool in
      return !activeOperations.contains(operation)
    }
    let operationCount = operationsLeft.count - 1
    let randNew = Int.random(0...operationCount)
    self.activeOperations.append(operationsLeft[randNew])
  }
  
  func randomActiveOperations() -> Array<Operation> {
    var operations: Array<Operation> = []
    let activeOperation = randomActiveOperation()
    operations.append(activeOperation)
    if multipleOperationsDisplayActive {
      switch activeOperation {
      case .Add, .Subtract:
        let rand = Int.random(2...3)
        operations.append(Grid.operations[rand])
      default:
        let rand = Int.random(0...1)
        operations.append(Grid.operations[rand])
      }
    }
    return operations
  }
  
  func randomActiveOperation() -> Operation {
    let operationCount = activeOperations.count - 1
    let randIndex = Int.random(0...operationCount)
    return activeOperations[randIndex]
  }
  
  
  // MARK: Tiles
  var numberOfTiles = 3
  func increaseNumberOfTiles() {
    numberOfTiles += 2
  }
  
  // MARK: Range
  var range: Int {
    get {
      return MultipleHelper.defaultHelper.range
    }
    set {
      MultipleHelper.defaultHelper.increaseRange()
    }
  }
  
  // MARK: Time (should time stack? - no each round is different, just need to get to the end)
  var standardRoundDuration: Int = 120
  var standardBoostTime: Int = 15
  func decreaseStandardRoundDuration() {
    standardRoundDuration -= 20
  }
  func decreaseStandardBoostTime() {
    standardBoostTime -= 5
  }
  
  // MARK: Helper Points
  var currentHelperPoints: Int = 3
  func helperPointUtilized() {
    currentHelperPoints -= 1
  }
  
  func helperPointsForNewRound() {
    currentHelperPoints += 3
  }
  
  
}