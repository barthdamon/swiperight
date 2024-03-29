//
//  GameViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
  
//  @IBOutlet weak var borderView: UIView!
//  @IBOutlet weak var borderTwo: UIView!
//  @IBOutlet weak var borderOne: UIView!
//  @IBOutlet weak var operationFlashImage: UIImageView!
  @IBOutlet weak var operationFlashText: UILabel!
  @IBOutlet weak var operationFlashView: UIView!
  @IBOutlet weak var tutorialLaunchTextLabel: UILabel!
  
  @IBOutlet weak var view00: TileView!
  @IBOutlet weak var view10: TileView!
  @IBOutlet weak var view20: TileView!
  @IBOutlet weak var view01: TileView!
  @IBOutlet weak var view11: TileView!
  @IBOutlet weak var view21: TileView!
  @IBOutlet weak var view02: TileView!
  @IBOutlet weak var view12: TileView!
  @IBOutlet weak var view22: TileView!
  
  @IBOutlet weak var subview00: UIView!
  @IBOutlet weak var subview10: UIView!
  @IBOutlet weak var subview20: UIView!
  @IBOutlet weak var subview01: UIView!
  @IBOutlet weak var subview11: UIView!
  @IBOutlet weak var subview21: UIView!
  @IBOutlet weak var subview12: UIView!
  @IBOutlet weak var subview02: UIView!
  @IBOutlet weak var subview22: UIView!
  
  @IBOutlet weak var label00: UILabel!
  @IBOutlet weak var label10: UILabel!
  @IBOutlet weak var label20: UILabel!
  @IBOutlet weak var label01: UILabel!
  @IBOutlet weak var label11: UILabel!
  @IBOutlet weak var label21: UILabel!
  @IBOutlet weak var label02: UILabel!
  @IBOutlet weak var label12: UILabel!
  @IBOutlet weak var label22: UILabel!
  
  var numberLabels: Array<UILabel> = []
  var tileViews: Array<TileView> = []
  var tileSubviews: Array<UIView> = []
  
  var gameLaunchController: GameLaunchViewController?
  var helperPointController: HelperPointViewController?
  var delegate: GameViewDelegate?
  var containerView: UIView?
  
  var countingDown: Bool = false
  

  
//  var coinSound: NSURL? = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("coin", ofType: "wav"))
  
  var gradientLayer: CAGradientLayer?
  var tileWidth: CGFloat!
  var viewWidth: CGFloat!
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  var currentLoc: CGPoint?
  var flashingOperation: Bool = false
  
  var previousOperations: Array<Operation> = []
  
  var intermissionTimeLabel: UILabel?
  var intermissionTime: Int = 20 {
    didSet {
      intermissionTimeLabel?.text = "Next Round Starts: \(intermissionTime)"
    }
  }
  var tutorialText: String?
  
  var currentLayout: GridNumberLayout? {
    didSet {
      self.delegate?.resetClientOperations(currentLayout?.operations)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SoundManager.defaultManager.loadSoundFiles()
    if let container = self.containerView {
      self.viewWidth = container.bounds.width
      tileWidth = container.bounds.width / 3
    }
    self.view.backgroundColor = ThemeHelper.defaultHelper.sw_gameview_background_color
    self.view.userInteractionEnabled = false
    configureGameViewComponents()
    if GameStatus.status.gameMode == .Tutorial {
      GameStatus.status.tutorialStage += 2
      delegate?.setTutorialLabelText("Swipe from the beginning to the end of the equation!")
      self.resetTiles()
    } else {
      animateBeginGame()
    }
  }

  
  func appendViews() {
    numberLabels.append(label00)
    numberLabels.append(label10)
    numberLabels.append(label20)
    numberLabels.append(label01)
    numberLabels.append(label11)
    numberLabels.append(label21)
    numberLabels.append(label02)
    numberLabels.append(label12)
    numberLabels.append(label22)
    
    tileViews.append(view00)
    tileViews.append(view10)
    tileViews.append(view20)
    tileViews.append(view01)
    tileViews.append(view11)
    tileViews.append(view21)
    tileViews.append(view02)
    tileViews.append(view12)
    tileViews.append(view22)
    
    tileSubviews.append(subview00)
    tileSubviews.append(subview10)
    tileSubviews.append(subview20)
    tileSubviews.append(subview01)
    tileSubviews.append(subview11)
    tileSubviews.append(subview21)
    tileSubviews.append(subview02)
    tileSubviews.append(subview12)
    tileSubviews.append(subview22)
  }
  
  func configureGameViewComponents() {
    appendViews()
    
    for (i, tile) in tileViews.enumerate() {
      tile.setup(numberLabels[i], subview: tileSubviews[i], overlay: false, coordinates: Grid.tileCoordinates[i])
    }
    
//    borderOne.layer.borderWidth = 2
//    borderOne.layer.borderColor = ThemeHelper.defaultHelper.sw_tile_separator_color.CGColor
//    borderTwo.layer.borderWidth = 2
//    borderTwo.layer.borderColor = ThemeHelper.defaultHelper.sw_tile_separator_color.CGColor
//    borderView.layer.borderWidth = 2
//    borderView.layer.borderColor = ThemeHelper.defaultHelper.sw_tile_separator_color.CGColor
    
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    startLoc = touch.locationInView(self.view)
    endLoc = touch.locationInView(self.view)
    currentLoc = touch.locationInView(self.view)
    selectTileForGestureLocation()
    if inTutorialHighlightMode {
      tutorialResolveHighlightMovement()
    }
    print("Touches began")
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    let end = touch.locationInView(self.view)
    selectTileForGestureLocation()
    currentLoc = touch.locationInView(self.view)
    if (end.x > 0 && end.y > 0) && (end.x < self.view.frame.width && end.y < self.view.frame.height) {
      endLoc = touch.locationInView(self.view)
      if inTutorialHighlightMode {
        // resolve user interaction?
        tutorialResolveHighlightMovement()
      }
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    let end = touch.locationInView(self.view)
    if (end.x > 0 && end.y > 0) && (end.x < self.view.frame.width && end.y < self.view.frame.height) {
      endLoc = end
    }
    tileViews.forEach({$0.deselect()})
    resolveUserInteraction()
    print("Touches ended")
  }
  
  func selectTileForGestureLocation() {
    if GameStatus.status.gameActive {
      if let currentLoc = currentLoc {
        let current = (x: Int(currentLoc.x / tileWidth), y: Int(currentLoc.y / tileWidth))
        var currentTile: TileView?
        for i in 0 ..< Grid.tileCoordinates.count {
          let loc = Grid.tileCoordinates[i]
          if loc.x == current.x && loc.y == current.y {
            currentTile = tileViews[i]
          }
        }
        tileViews.forEach({ (tile) in
          if tile != currentTile {
            tile.deselect()
          } else {
            tile.drawSelected()
          }
        })
      }
    }
  }
  
  func resolveUserInteraction() {
    if GameStatus.status.gameActive {
      if let startLoc = startLoc, endLoc = endLoc {
        var startTile: TileView?
        var endTile: TileView?
        var midTile: TileView?
        var tileIndexes: Array<Int> = []
        //Int floors the cgfloat
        let start = (x: Int(startLoc.x / tileWidth), y: Int(startLoc.y / tileWidth))
        print("START: \(start.x), \(start.y)")
        
        let end = (x: Int(endLoc.x / tileWidth), y: Int(endLoc.y / tileWidth))
        print("END: \(end.x), \(end.y)")
        
        let mid = (x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        print("MIDDLE: \(mid.x), \(mid.y)")
        
        for i in 0 ..< Grid.tileCoordinates.count {
          let loc = Grid.tileCoordinates[i]
          if loc.x == start.x && loc.y == start.y {
            startTile = tileViews[i]
            print("START TILE FOUND: \(i)")
            tileIndexes.append(i)
          }
          if loc.x == end.x && loc.y == end.y {
            endTile = tileViews[i]
            print("END TILE FOUND: \(i)")
            tileIndexes.append(i)
          }
          if loc.x == mid.x && loc.y == mid.y {
            midTile = tileViews[i]
            print("MID TILE FOUND: \(i)")
            tileIndexes.append(i)
          }
        }
        
        if let startTile = startTile, midTile = midTile, endTile = endTile {
          //check if the tileviews stack in a valid combination of index
          var valid = false
          for combo in Grid.combinations {
            if combo[0] == tileIndexes[0] && combo[1] == tileIndexes[1] && combo[2] == tileIndexes[2] {
              valid = true
            }
          }
          if valid {
            tileRespond(startTile, middleTile: midTile, endTile: endTile)
            self.startLoc = nil
            self.endLoc = nil
          } else {
            if inTutorialHighlightMode {
              // resolve user interaction?
              resetTilesToHighlight(true)
            }
            self.startLoc = nil
            self.endLoc = nil
          }
        } else if inTutorialHighlightMode {
          // resolve user interaction?
          resetTilesToHighlight(true)
        }
      }
    }
  }
  
  func checkForCorrect(operations: Array<Operation>, start: Int, mid: Int, end: Int) -> Bool {
    var found = false
    for operation in operations {
      switch operation {
      case .Add:
        if start + mid == end {
          found = true
        }
      case .Subtract:
        if start - mid == end {
          found = true
        }
      case .Divide:
        if start != 0 && mid != 0 && end != 0 {
          if start / mid == end {
            found = true
          }
        }
      case .Multiply:
        if start * mid == end {
          found = true
        }
      }
    }
    return found
  }
  
  
  func tileRespond(startTile: TileView, middleTile: TileView, endTile: TileView) {
    if GameStatus.status.gameActive && tilesActive(startTile, middleTile: middleTile, endTile: endTile) {
      print("TILE RESPOND TIME")
      if let operations = currentLayout?.operations, startNumber = startTile.number, midNumber = middleTile.number, endNumber = endTile.number {
        guard let winningOp = currentLayout?.winningCombination?.operation else { return }
        if checkForCorrect(operations, start: startNumber, mid: midNumber, end: endNumber) {
          delegate?.scoreChange(true)
          self.view.backgroundColor = winningOp.color
          self.gradientLayer?.removeFromSuperlayer()
          self.view.userInteractionEnabled = false
          SoundManager.defaultManager.playSound(.Correct)
          startTile.drawCorrect(winningOp, callback: { (success) in
            middleTile.drawCorrect(winningOp, callback: { (success) in
              endTile.drawCorrect(winningOp, callback: { (success) in
                if GameStatus.status.gameMode == .Standard {
                  self.delegate?.addTime(ProgressionManager.sharedManager.standardBoostTime)
                  self.helperStreakActivity(true)
                  waitASec(0.3, callback: { (done) in
                    self.endResponse()
                  })
                } else {
                  self.tutorialEndResponse(true)
                }
              })
            })
          })
        } else {
          delegate?.scoreChange(false)
          self.view.backgroundColor = winningOp.color
          self.gradientLayer?.removeFromSuperlayer()
          SoundManager.defaultManager.playSound(.Incorrect)
          startTile.drawIncorrect(winningOp)
          endTile.drawIncorrect(winningOp)
          middleTile.drawIncorrect(winningOp)
          self.view.userInteractionEnabled = false
          if GameStatus.status.gameMode == .Standard {
            self.helperStreakActivity(false)
            waitASec(0.3, callback: { (done) in
              self.endResponse()
            })
          } else {
            waitASec(0.3, callback: { (done) in
              self.tutorialEndResponse(false)
            })
          }
        }
      }
    }
  }
  
  func endResponse() {
    ProgressionManager.sharedManager.currentRoundPosition += 1
    if ProgressionManager.sharedManager.currentRoundPosition > ProgressionManager.sharedManager.roundLength {
      newRound()
    }
    resetTiles()
  }
  
  func tilesActive(startTile: TileView, middleTile: TileView, endTile: TileView) -> Bool {
    if startTile.userInteractionEnabled && middleTile.userInteractionEnabled && endTile.userInteractionEnabled {
      return true
    } else {
      return false
    }
  }
  
  func resetTiles() {
    if GameStatus.status.gameMode == .Standard {
      if GameStatus.status.gameActive {
        self.currentLayout = GridNumberLayout()
        self.gradientLayer?.removeFromSuperlayer()
        animateTileReset()
      }
    } else {
      print(GameStatus.status.tutorialStage)
      switch GameStatus.status.tutorialStage {
      case 2:
        ProgressionManager.sharedManager.setOperationsAsActive([.Add])
        self.currentLayout = GridNumberLayout()
        resetTilesToHighlight(false)
      case 5:
        // set two operations active with two potential combinations
        // make two operations active with range still minimalf
        if solvedOneOnFive {
          ProgressionManager.sharedManager.setOperationsAsActive([.Divide])
        } else {
          ProgressionManager.sharedManager.setOperationsAsActive([.Subtract])
        }
        ProgressionManager.sharedManager.numberOfExtraTiles = 2
        MultipleHelper.defaultHelper.range = 10
        self.currentLayout = GridNumberLayout()
//        ProgressionManager.sharedManager.currentLayoutOperationCount = 2
        guard let operation = currentLayout?.winningCombination?.operation else { return }
        self.gradientLayer?.removeFromSuperlayer()
        let text = solvedOneOnFive ? "Now solve this one for" : "Solve for"
        ProgressionManager.sharedManager.previousOperations = [operation]
        delegate?.setTutorialLabelText("\(text) \(operation.rawValue)!")
        animateTileReset()
        resetTilesToHighlight(true)
      case 8:
        self.delegate?.deactivateHelperPointButton(false, deactivate: false)
        ProgressionManager.sharedManager.reset()
        ProgressionManager.sharedManager.setOperationsAsActive([.Add])
        ProgressionManager.sharedManager.numberOfExtraTiles = 2
        MultipleHelper.defaultHelper.range = 20
        ProgressionManager.sharedManager.currentHelperPoints = 0
        ProgressionManager.sharedManager.currentStreak = 0
        delegate?.setStreakLabel()
        self.currentLayout = GridNumberLayout()
        self.gradientLayer?.removeFromSuperlayer()
        if !tutorialTimeForHelper {
          delegate?.setTutorialLabelText("Complete three in a row to get an ability point!")
        }
        delegate?.hideBonusButtonView(false)
        animateTileReset()
      default:
        break
      }
    }
  }
  
  func setGameViewBackground(operations: Array<Operation>) {
    self.gradientLayer?.removeFromSuperlayer()
    var color: UIColor = UIColor.darkGrayColor()
    if operations.count == 1 {
      color = operations[0].color
      self.view.backgroundColor = color
    } else {
      let firstOperation = operations.filter({if $0 == .Add || $0 == .Subtract {
        return true
      } else {
        return false
        }})
      let firstColor = firstOperation[0].color
      let secondOperation = operations.filter({$0 == .Multiply || $0 == .Divide})
      let secondColor = secondOperation[0].color
      gradientLayer = CAGradientLayer.gradientLayerForBounds(self.view.bounds, colors: (start: firstColor, end: secondColor))
      self.view.layer.hidden = false
      self.view.layer.insertSublayer(gradientLayer!, atIndex: 0)
      // half and half
    }

  }
  
  func fadeOutTiles(callback: (complete: Bool) -> ()) {
//    self.borderView.alpha = 0
    for (i, tile) in tileViews.enumerate() {
//      tile.showBorder(false)
      tile.drawNormal({ (complete) in
        if i == self.tileViews.count - 1 {
          callback(complete: true)
        }
      })
    }
  }
  
  func fadeInTiles() {
    tileViews.forEach { (tile) -> () in
      tile.showBorder(true)
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        tile.numberLabel?.alpha = tile.number == -1 ? 0 : 1
//        self.borderView.alpha = 1
        }, completion: { (complete) -> Void in
          self.delegate?.activateHelperButtons()
          GameStatus.status.resettingTiles = false
          if GameStatus.status.gameMode == .Standard {
            self.view.userInteractionEnabled = true
//            self.delegate?.beginGame()
          } else {
            GameStatus.status.gameActive = true
            if GameStatus.status.tutorialStage == 8 && self.tutorialTimeForHelper {
              self.view.userInteractionEnabled = false
              self.view.alpha = 0.4
            } else {
              self.view.userInteractionEnabled = true
              self.view.alpha = 1
            }
          }
      })
    }
  }
  
  func flashCurrentOperation(operations: Array<Operation>, callback: (Bool) -> ()) {
    let flashAlpha: CGFloat = 1.0
    if (operations.count > 1) {
      if previousOperations.contains(operations[0]) && previousOperations.contains(operations[1]) {
        callback(false)
      } else {
        let firstOperation = operations.filter({$0 == .Add || $0 == .Subtract})
        let secondOperation = operations.filter({$0 == .Multiply || $0 == .Divide})
        if let first = firstOperation.first?.flashName, second = secondOperation.first?.flashName {
          self.operationFlashText.text = "\(first)\nOR\n\(second)"
        }
        self.operationFlashText.alpha = flashAlpha
        waitASec(0.7, callback: { (done) in
          self.previousOperations = operations
          self.operationFlashText.alpha = 0
          callback(true)
        })
      }
    } else if previousOperations.count == 1 {
      if previousOperations[0] == operations.first {
        callback(false)
      } else {
        self.operationFlashText.text = operations.first?.flashName
        self.operationFlashText.alpha = flashAlpha
        waitASec(0.7, callback: { (done) in
          self.operationFlashText.alpha = 0
          self.previousOperations = operations
          callback(true)
        })
      }
    } else {
      self.operationFlashText.text = operations.first?.flashName
      self.operationFlashText.alpha = flashAlpha
      waitASec(0.7, callback: { (done) in
        self.operationFlashText.alpha = 0
        self.previousOperations = operations
        callback(true)
      })
    }
  }
  
  func animateTileReset() {
    GameStatus.status.resettingTiles = true
    fadeOutTiles { (complete) in
      guard let layout = self.currentLayout else { return }
      self.setGameViewBackground(layout.operations)
      self.tileViews.forEach({$0.showBorder(false)})
      self.flashingOperation = true
      self.flashCurrentOperation(layout.operations, callback: { (done) in
        self.flashingOperation = false
        self.tileViews.forEach({$0.showBorder(true)})
        self.applyNumberLayoutToTiles(false)
        self.fadeInTiles()
      })
    }
  }
  
  func applyNumberLayoutToTiles(reset: Bool) {
    if let layout = currentLayout, indexes = layout.solutionIndexes {
      for i in 0 ..< layout.numbers.count {
        if reset {
          tileViews[i].numberLabel?.alpha = 0
        } else {
          tileViews[i].number = layout.numbers[i]
          tileViews[i].numberLabel?.alpha = 0
          if indexes.contains(i) {
            tileViews[i].partOfSolution = true
          } else {
            tileViews[i].partOfSolution = false
          }
        }
      }
    }
  }
  
  func animateBeginGame() {
    self.delegate?.countingDown(true)
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      if let text = self.tutorialText {
        self.tutorialLaunchTextLabel.text = text
        self.tutorialLaunchTextLabel.hidden = false
      }
      self.delegate?.setTutorialLabelText("There is always only one correct equation!")
      self.tileViews.forEach { (view) in
        view.animateCountdown({ (done) in
          if done {
            if let delegate = self.delegate where !delegate.timerAlreadyTocking() {
              self.delegate?.setTutorialLabelText(nil)
              self.tutorialLaunchTextLabel.hidden = true
              self.tutorialText = nil
              self.delegate?.setStartTime()
              GameStatus.status.gameActive = true
              self.resetTiles()
              self.delegate?.countingDown(false)
              self.delegate?.startGameplay()
            }
          }
        })
      }
    })
  }
  
  func newRound() {
    ProgressionManager.sharedManager.currentRound += 1
    ProgressionManager.sharedManager.currentRoundPosition = 1
    
    if ProgressionManager.sharedManager.currentRound < 19 {
      if let modification = ProgressionManager.sharedManager.generateRandomModification() {
        ProgressionManager.sharedManager.newModificationSelected(modification)
      }
      //      GameStatus.status.gameActive = true
      //      resetRound()
    }
    
    self.delegate?.setRound(ProgressionManager.sharedManager.currentRound)
  }
  
  func helperStreakActivity(correct: Bool) -> Bool {
//    guard let operation = self.currentLayout?.winningCombination?.operation else { return false }
    if correct {
      let streakReached = ProgressionManager.sharedManager.increaseStreak()
      if streakReached {
        ProgressionManager.sharedManager.helperPointsForReachedStreak()
        delegate?.setHelperPoints(ProgressionManager.sharedManager.currentHelperPoints, callback: { (done) in
          ProgressionManager.sharedManager.resetStreak()
          self.delegate?.setStreakLabel()
        })
      } else {
        delegate?.setStreakLabel()
      }
      return streakReached
    } else {
      ProgressionManager.sharedManager.resetStreak()
      delegate?.setStreakLabel()
      return false
    }
  }
  
  
  
  
  
 // MARK: Helpers
  func helperSelected(helper: HelperPoint) {
    guard let layout = currentLayout, combo = layout.winningCombination, indexes = layout.solutionIndexes else { return }
    switch helper {
    case .Hide:
      if GameStatus.status.gameMode == .Tutorial && GameStatus.status.tutorialStage == 8 && !backFromTutorialHelper {
        self.view.alpha = 1
        self.delegate?.setTutorialLabelText("One less tile to distract you now!")
        self.view.userInteractionEnabled = true
        backFromTutorialHelper = true
      }

      // get all the indexes that arent in
      let possibleIndexes = Grid.indexes.filter({!indexes.contains($0)})
      // index of the tile view needs to be the samiae
      var possibleRemovals: Array<TileView> = []
      for (index, tile) in tileViews.enumerate() {
        if possibleIndexes.contains(index) && tile.active && !tile.drawnIncorrect {
          possibleRemovals.append(tile)
        }
      }
      let removalCount = possibleRemovals.count - 1
      let randRemovalIndex = Int.random(0...removalCount)
      // hide one
      possibleRemovals[randRemovalIndex].drawIncorrect(combo.operation)
      possibleRemovals[randRemovalIndex].numberLabel?.alpha = 0
      ProgressionManager.sharedManager.helperPointUtilized(.Hide)
    case .Reveal:
      var possibleReveals: Array<TileView> = []
      for (index, tile) in tileViews.enumerate() {
        if indexes.contains(index) && tile.active && !tile.drawnIncorrect && !tile.drawnCorrect {
          possibleReveals.append(tile)
        }
      }
      
      let revealCount = possibleReveals.count - 1
      let randRevealIndex = Int.random(0...revealCount)
      // reveal one
      possibleReveals[randRevealIndex].drawCorrect(combo.operation, callback: { (done) in
      })
      // light up a tile selected
      ProgressionManager.sharedManager.helperPointUtilized(.Reveal)
    case .Remove:
      let filteredOperations = ProgressionManager.sharedManager.activeOperations.filter({$0 == combo.operation})
      currentLayout?.operations = filteredOperations
      delegate?.resetClientOperations(filteredOperations)
      setGameViewBackground(filteredOperations)
      ProgressionManager.sharedManager.helperPointUtilized(.Remove)
    }
    SoundManager.defaultManager.playSound(.AbilityUse)
    delegate?.deactivateHelperPointButton(false, deactivate: false)
    delegate?.setHelperPoints(ProgressionManager.sharedManager.currentHelperPoints, callback: { (done) in })
//    delegate?.togglePaused(false)
  }
  
  func helperButtonPressed() {
    self.performSegueWithIdentifier("showHelperPointController", sender: self)
  }
  
  func sendToPausedView() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.performSegueWithIdentifier("showPausedSegue", sender: self)
    })
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showHelperPointController" {
      if let vc = segue.destinationViewController as? HelperPointViewController {
//        delegate?.togglePaused(true)
        delegate?.hideBonusButtonView(true)
        vc.delegate = delegate
        helperPointController = vc
        vc.gameViewController = self
      }
    }
    
    if segue.identifier == "showPausedSegue" {
      if let vc = segue.destinationViewController as? PausedViewController {
        vc.delegate = delegate
      }
    }
    
    if segue.identifier == "showTutorialSegue" {
      if let vc = segue.destinationViewController as? HelperHelpViewController {
        vc.delegate = delegate
        vc.gameViewController = self
        vc.fromPointController = false
      }
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  // MARK: Tutorial
  
  var highlightTileTimer: NSTimer?
  var tilesToHighlight: Array<TileView> = []
  var inTutorialHighlightMode: Bool = false
  var tutorialTimeForHelper: Bool = false
  var backFromTutorialHelper: Bool = false
  var solvedOneOnFive: Bool = false
  var pausingForEffect: Bool = false
  
  func showTutorialText() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.highlightTileTimer?.invalidate()
      self.highlightTileTimer = nil
      ProgressionManager.sharedManager.reset()
      self.performSegueWithIdentifier("showTutorialSegue", sender: self)
    })
  }
  
  func highlightNextTile() {
    if tilesToHighlight.count > 0 {
      tilesToHighlight.removeFirst()
      // add it to the highlighted tiles, remove it from the tiles to highlight
    }
    if GameStatus.status.tutorialStage == 2 {
      if tilesToHighlight.count == 3 {
        delegate?.setTutorialLabelText("Swipe from the beginning to the end of the equation!")
      } else if tilesToHighlight.count == 2 {
        delegate?.setTutorialLabelText("Swipe to the next tile!")
      } else if tilesToHighlight.count == 1 {
        delegate?.setTutorialLabelText("Keep swiping!")
      }else if tilesToHighlight.count == 0 {
        delegate?.setTutorialLabelText("Now lift your finger!")
      }
    }
//    highlightTiles()
    // when last one reaced showTutorial text
  }
  
  func tutorialEndResponse(correct: Bool) {
    if GameStatus.status.tutorialStage == 8 && !tutorialTimeForHelper {
      if backFromTutorialHelper {
        let text = correct ? "Well done!" : "Don't worry, just a tutorial!"
        self.delegate?.setTutorialLabelText(text)
        pausingForEffect = true
        waitASec(0.3) { (done) in
          self.pausingForEffect = false
          self.delegate?.setTutorialLabelText(nil)
          self.delegate?.resetGameUI()
          self.delegate?.deactivateHelperPointButton(true, deactivate: true)
          self.showTutorialText()
        }
      } else {
        self.currentLayout = GridNumberLayout()
        self.gradientLayer?.removeFromSuperlayer()
        if correct {
          if helperStreakActivity(true) {
            self.delegate?.setTutorialLabelText("Hide a tile with your ability point!")
            tutorialTimeForHelper = true
            delegate?.deactivateHelperPointButton(false, deactivate: false)
//            delegate?.setBlinkingHelperPointsOn(true, withStreaks: false, hideStreaks: false)
          }
        } else {
          helperStreakActivity(false)
        }
        animateTileReset()
      }
    } else if GameStatus.status.tutorialStage == 5 {
      if solvedOneOnFive {
        self.inTutorialHighlightMode = false
        self.highlightTileTimer?.invalidate()
        self.highlightTileTimer = nil
        let text = correct ? "You're getting the hang of this!" : "You'll get it next time!"
        self.delegate?.setTutorialLabelText(text)
        pausingForEffect = true
        waitASec(1.0) { (done) in
          // Right before helper points
          self.pausingForEffect = false
          GameStatus.status.tutorialStage += 3
          self.resetTiles()
//          self.delegate?.setTutorialLabelText(nil)
//          self.delegate?.resetGameUI()
//          self.showTutorialText()
        }
      } else {
        solvedOneOnFive = true
        self.inTutorialHighlightMode = false
        self.highlightTileTimer?.invalidate()
        self.highlightTileTimer = nil
        ProgressionManager.sharedManager.setOperationsAsActive([.Divide])
        self.currentLayout = GridNumberLayout()
        self.gradientLayer?.removeFromSuperlayer()
        guard let operation = currentLayout?.winningCombination?.operation else { return }
        let text = solvedOneOnFive ? "Now try solving this one for" : "Solve for"
        delegate?.setTutorialLabelText("\(text) \(operation.rawValue)!")
        animateTileReset()
      }
    } else {
      let text = correct ? "Nice!" : "You'll get it next time!"
      delegate?.setTutorialLabelText(text)
      self.inTutorialHighlightMode = false
      self.highlightTileTimer?.invalidate()
      self.highlightTileTimer = nil
      pausingForEffect = true
      waitASec(1.0) { (done) in
        self.pausingForEffect = false
//        self.delegate?.setTutorialLabelText(nil)
          // right after first one
        if GameStatus.status.tutorialStage != 8 {
          GameStatus.status.tutorialStage += 3
          self.resetTiles()
        } else {
          self.delegate?.resetGameUI()
          self.delegate?.deactivateHelperPointButton(true, deactivate: true)
          self.delegate?.launchForEndTutorial("Woohoo! you got this!")
        }
//        self.delegate?.resetGameUI()
//        self.showTutorialText()
      }
    }
  }
  
  func highlightNext(operation: Operation, index: UInt) {
    do {
      let highlight = try tilesToHighlight.lookup(index)
      highlight.highlightForTutorial(self, operation: operation, callback: { (done) in
        self.highlightNext(operation, index: index + 1)
      })
    }
    catch {
      return
    }
  }
  
  func highlightTiles() {
    if !pausingForEffect && !flashingOperation {
      guard let operation = currentLayout?.winningCombination?.operation else { return }
      highlightNext(operation, index: 0)
    }
  }
  
  func resetTilesToHighlight(userBlewIt: Bool) {
    highlightTileTimer?.invalidate()
    highlightTileTimer = nil
    tilesToHighlight.removeAll()
    if !userBlewIt {
      self.currentLayout = GridNumberLayout()
      self.gradientLayer?.removeFromSuperlayer()
      self.animateTileReset()
    }
    // set first one to glowing, and respond only when they move to the correct one
    guard let combo = currentLayout?.winningCombination else { return }
    tilesToHighlight.append(tileViews[combo.xNumberIndex])
    tilesToHighlight.append(tileViews[combo.bNumberIndex])
    tilesToHighlight.append(tileViews[combo.sumNumberIndex])
    if GameStatus.status.tutorialStage == 2 {
      delegate?.setTutorialLabelText("Swipe from the beginning to the end of the equation!")
    }
    if GameStatus.status.tutorialStage == 5 && tilesToHighlight.count != 0 {
      if let op = currentLayout?.winningCombination?.operation {
        delegate?.setTutorialLabelText("Solve for \(op.rawValue)!")
      }
    }
    inTutorialHighlightMode = true
    GameStatus.status.gameActive = true
    highlightTileTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GameViewController.highlightTiles), userInfo: nil, repeats: true)
  }
  
  
  func setGameViewForTutorialStage() {
    self.navigationController?.popViewControllerAnimated(true)
    self.resetTiles()
  }
  
  func tutorialResolveHighlightMovement() {
    guard let endLoc = endLoc else { return }
    let end = (x: Int(endLoc.x / tileWidth), y: Int(endLoc.y / tileWidth))
    var currentTile: TileView?
    for i in 0 ..< Grid.tileCoordinates.count {
      let loc = Grid.tileCoordinates[i]
      if loc.x == end.x && loc.y == end.y {
        currentTile = tileViews[i]
      }
    }
    if let tile = currentTile {
      if tilesToHighlight.contains(tile) {
        if let first = tilesToHighlight.first {
          if first == tile {
            highlightNextTile()
          }
        }
      }
    }
    if GameStatus.status.tutorialStage == 5 && tilesToHighlight.count == 0 {
      delegate?.setTutorialLabelText("Keep Solving!")
    }
  }

  
}
