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

enum ModificationType : Int {
  case Tile
  case BoostTime
  case RoundTime
  case Operation
  case Range
}

struct Modification {
  
  var type: ModificationType = .Tile
  var remaining: Int = 0
  
  init(type: ModificationType) {
    self.type = type
    switch type {
    case .Tile:
      remaining = 5
    case .RoundTime:
      remaining = 5
    case .BoostTime:
      remaining = 4
    case .Operation:
      remaining = 4
    case .Range :
      remaining = 5
    }
  }
}

class ProgressionManager: NSObject {
  
  static var sharedManager = ProgressionManager()
  
  // MARK: General
  var currentRound = 1
  var currentRoundPosition = 1
  let roundLength: Int = 4
  var modificationTypes: Array<ModificationType> = [.Tile, .BoostTime, .RoundTime, .Operation, .Range]
  var modifications: Array<Modification> = []
  
  
  override init() {
    super.init()
    modificationTypes.forEach { (mod) in
      modifications.append(Modification(type: mod))
    }
  }
  
  func generateRoundModifications() -> Array<Modification> {
    var newMods: Array<Modification> = []
    var numberOfMods = 0
    var modsRemaining = modifications.filter({$0.remaining > 0})
    repeat {
      let randModIndex = Int.random(0...modsRemaining.count)
      let newMod = modsRemaining[randModIndex]
      newMods.append(newMod)
      modsRemaining.removeAtIndex(randModIndex)
      if modsRemaining.count > 0 {
        numberOfMods += 1
      } else {
        newMods.append(newMod)
        numberOfMods = 2
      }
    } while numberOfMods < 2
    
    return newMods
  }
  
  func newModificationSelected(mod: Modification) {
    guard mod.remaining > 0 else { return }
    switch mod.type {
    case .Tile:
      increaseNumberOfTiles()
    case .RoundTime:
      decreaseStandardRoundDuration()
    case .BoostTime:
      decreaseStandardBoostTime()
    case .Operation:
      addRandomOperation()
    case .Range :
      MultipleHelper.defaultHelper.increaseRange()
    }
  }
  
  
  
  // MARK: Operations
  // get a random one for this, but then get random other when progression at that level for the UI
  var activeOperations: Array<Operation> = [.Add]
  var multipleOperationsDisplayActive: Bool = false
  func addRandomOperation() {
    let operationsLeft = Grid.operations.filter { (operation) -> Bool in
      return !activeOperations.contains(operation)
    }
    let operationLeftCount = operationsLeft.count - 1
    if operationLeftCount >= 0 {
      let randNew = Int.random(0...operationLeftCount)
      self.activeOperations.append(operationsLeft[randNew])
    } else {
      multipleOperationsDisplayActive = true
    }
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
  var numberOfExtraTiles = 0
  func increaseNumberOfTiles() {
    if numberOfExtraTiles == 0 {
      numberOfExtraTiles += 2
    } else if numberOfExtraTiles < 6 {
      numberOfExtraTiles += 1
    }
  }
  
  // MARK: Range
  var range: Int {
    return MultipleHelper.defaultHelper.range
  }
  
  // MARK: Time
  var standardRoundDuration: Int = 120
  func decreaseStandardRoundDuration() {
    standardRoundDuration -= 20
  }
  var standardBoostTime: Int = 15
  func decreaseStandardBoostTime() {
    standardBoostTime -= 3
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