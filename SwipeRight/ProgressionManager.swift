//
//  ProgressionManager.swift
//  SwipeRight
//
//  Created by Matthew Barth on 5/15/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit


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

enum ModificationType : String {
  case Tile = "Extra Tiles"
  case BoostTime = "Boost Time"
  case RoundTime = "Round Time"
  case Operation = "Operations"
  case Range = "Number Range"
}

enum HelperPoint {
  case Hide
  case Remove
  case Reveal
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
    case .Range:
      remaining = 9
    }
  }
}

class ProgressionManager: NSObject {
  
  static var sharedManager = ProgressionManager()
  
  // MARK: General
  var currentRound = 1
  var currentRoundPosition = 1
  let roundLength: Int = 3
  var modificationTypes: Array<ModificationType> = [.Tile, .Operation, .Range]
  var modifications: Array<Modification> = []
  var previousModificationTypes: Array<ModificationType> = []
  
  override init() {
    super.init()
    modificationTypes.forEach { (mod) in
      modifications.append(Modification(type: mod))
    }
  }
  
  func reset() {
    modifications.removeAll()
    modificationTypes.forEach { (mod) in
      modifications.append(Modification(type: mod))
    }
    currentRound = 1
    standardRoundDuration = 20
    standardBoostTime = 5
    MultipleHelper.defaultHelper.resetRange()
    currentHelperPoints = 0
    numberOfExtraTiles = 0
    self.activeOperations = [.Add]
    multipleOperationsDisplayActive = false
  }
  
  func generateRandomModification() -> Modification? {
    // make sure they are getting a balance so its fair
    // maybe take the past 4 and make sure there is at least one of each type....
    let modsRemaining = modifications.filter({$0.remaining > 0})
    // use the remaining...
    let maxIndex: Int = modsRemaining.count - 1
    let sortedMods = modsRemaining.sort({$0.remaining > $1.remaining})
    var newMod: Modification?
    
    
    func generateMod() {
      let randModIndex = Int.random(0...maxIndex)
      newMod = sortedMods[randModIndex]
      let neededMods = modsRemaining.filter({!previousModificationTypes.contains($0.type)})
      if neededMods.count > 0 {
        let randModIndexNeeded = Int.random(0...neededMods.count - 1)
        newMod = neededMods[randModIndexNeeded]
      }
    }
    print("Previous Modifications:")
    for prevMod in previousModificationTypes {
      print("\(prevMod.rawValue)")
    }
    
    generateMod()
    if let type = newMod?.type {
      previousModificationTypes.insert(type, atIndex: 0)
    }

    if (previousModificationTypes.count == modificationTypes.count) || (previousModificationTypes.count > modsRemaining.count) {
      previousModificationTypes.popLast()
    }
    
    return newMod
  }
  
  func newModificationSelected(mod: Modification) {
    guard mod.remaining > 0 else { return }
    for (index, modification) in self.modifications.enumerate() {
      if mod.type == modification.type {
        self.modifications[index].remaining -= 1
      }
    }
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
  var standardBoostTime: Int = 5
  func decreaseStandardBoostTime() {
    standardBoostTime -= 3
  }
  
  // MARK: Helper Points
  var currentHelperPoints: Int = 0
  func helperPointUtilized(helperPoint: HelperPoint) {
    switch helperPoint {
    case .Hide:
      currentHelperPoints -= 1
    case .Remove:
      currentHelperPoints -= 2
    case .Reveal:
      currentHelperPoints -= 3
    }
  }
  
  func helperPointsForNewRound() {
    currentHelperPoints += 1
  }
  
  
}