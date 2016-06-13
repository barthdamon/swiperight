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
  
  var gradientLayer: CAGradientLayer?
  var tileWidth: CGFloat!
  var viewWidth: CGFloat!
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  
  var intermissionTimeLabel: UILabel?
  var intermissionTime: Int = 20 {
    didSet {
      intermissionTimeLabel?.text = "Next Round Starts: \(intermissionTime)"
    }
  }
  
  var currentLayout: GridNumberLayout? {
    didSet {
      self.delegate?.resetClientOperations(currentLayout?.operations)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let container = self.containerView {
      self.viewWidth = container.bounds.width
      tileWidth = container.bounds.width / 3
    }
    self.view.backgroundColor = ThemeHelper.defaultHelper.sw_gameview_background_color
    self.view.userInteractionEnabled = false
    configureGameViewComponents()
    if GameStatus.status.gameMode == .Tutorial {
      self.performSegueWithIdentifier("showTutorialSegue", sender: self)
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
    print("Touches began")
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    let end = touch.locationInView(self.view)
    if (end.x > 0 && end.y > 0) && (end.x < self.view.frame.width && end.y < self.view.frame.height) {
      endLoc = touch.locationInView(self.view)
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    let end = touch.locationInView(self.view)
    if (end.x > 0 && end.y > 0) && (end.x < self.view.frame.width && end.y < self.view.frame.height) {
      endLoc = end
    }
    resolveUserInteraction()
    print("Touches ended")
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
            self.startLoc = nil
            self.endLoc = nil
          }
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
          startTile.makeBig()
          middleTile.makeBig()
          endTile.makeBig()
          startTile.drawCorrect(winningOp, callback: { (success) in
            middleTile.drawCorrect(winningOp, callback: { (success) in
              endTile.drawCorrect(winningOp, callback: { (success) in
                self.delegate?.addTime(ProgressionManager.sharedManager.standardBoostTime)
                self.helperStreakActivity(true)
                waitASec(0.15, callback: { (done) in
                  self.endResponse()
                })
              })
            })
          })
        } else {
          delegate?.scoreChange(false)
          startTile.drawIncorrect(winningOp)
          endTile.drawIncorrect(winningOp)
          middleTile.drawIncorrect(winningOp)
          self.view.userInteractionEnabled = false
          waitASec(0.15, callback: { (done) in
            self.helperStreakActivity(false)
            self.endResponse()
          })
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
    if GameStatus.status.gameActive {
      self.currentLayout = GridNumberLayout()
      self.gradientLayer?.removeFromSuperlayer()
      animateTileReset()
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
      tile.showBorder(false)
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
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        tile.numberLabel?.alpha = tile.number == -1 ? 0 : 1
//        self.borderView.alpha = 1
        }, completion: { (complete) -> Void in
          self.view.userInteractionEnabled = true
          self.delegate?.beginGame()
      })
    }
  }
  
  func animateTileReset() {
    fadeOutTiles { (complete) in
      guard let layout = self.currentLayout else { return }
      self.setGameViewBackground(layout.operations)
      self.applyNumberLayoutToTiles(false)
      self.fadeInTiles()
    }
  }
  
  func applyNumberLayoutToTiles(reset: Bool) {
    if let layout = currentLayout {
      for i in 0 ..< layout.numbers.count {
        if reset {
          tileViews[i].numberLabel?.alpha = 0
        } else {
          tileViews[i].number = layout.numbers[i]
          tileViews[i].numberLabel?.alpha = 0
        }
      }
    }
  }
  
  func animateBeginGame() {
    tileViews.forEach { (view) in
      view.animateCountdown({ (done) in
        if done {
          self.delegate?.setStartTime()
          GameStatus.status.gameActive = true
          self.resetTiles()
          self.delegate?.startGameplay()
          self.delegate?.toggleClientView()
        }
      })
    }
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
  
  func helperStreakActivity(correct: Bool) {
    if correct {
      ProgressionManager.sharedManager.currentStreak += 1
      if ProgressionManager.sharedManager.currentStreak == ProgressionManager.sharedManager.currentStreakNeeded {
        ProgressionManager.sharedManager.helperPointsForReachedStreak()
        ProgressionManager.sharedManager.resetStreak()
        delegate?.setHelperPoints(ProgressionManager.sharedManager.currentHelperPoints)
      } else {
        delegate?.setStreakLabel()
      }
    } else {
      ProgressionManager.sharedManager.resetStreak()
      delegate?.setStreakLabel()
    }
  }
  
  
  
  
  
 // MARK: Helpers
  func helperSelected(helper: HelperPoint) {
    guard let layout = currentLayout, combo = layout.winningCombination, indexes = layout.solutionIndexes else { return }
    switch helper {
    case .Hide:
      // get all the indexes that arent in
      let possibleIndexes = Grid.indexes.filter({!indexes.contains($0)})
      // index of the tile view needs to be the samiae
      var possibleRemovals: Array<TileView> = []
      for (index, tile) in tileViews.enumerate() {
        if possibleIndexes.contains(index) && tile.numberLabel!.hidden == false {
          possibleRemovals.append(tile)
        }
      }
      let removalCount = possibleRemovals.count - 1
      let randRemovalIndex = Int.random(0...removalCount)
      // hide one
      possibleRemovals[randRemovalIndex].drawIncorrect(combo.operation)
      ProgressionManager.sharedManager.helperPointUtilized(.Hide)
    case .Reveal:
      let randIndex = Int.random(0...2)
      let randSolutionIndex = indexes[randIndex]
      // reveal one
      self.tileViews[randSolutionIndex].drawCorrect(combo.operation, callback: { (done) in
      })
      // light up a tile selected
      ProgressionManager.sharedManager.helperPointUtilized(.Reveal)
    case .Remove:
      let filteredOperations = ProgressionManager.sharedManager.activeOperations.filter({$0 == combo.operation})
      delegate?.resetClientOperations(filteredOperations)
      setGameViewBackground(filteredOperations)
      ProgressionManager.sharedManager.helperPointUtilized(.Remove)
    }
    delegate?.deactivateHelperPointButton(false, deactivate: false)
    delegate?.setHelperPoints(ProgressionManager.sharedManager.currentHelperPoints)
    delegate?.togglePaused(false)
  }
  
  func helperButtonPressed() {
    self.performSegueWithIdentifier("showHelperPointController", sender: self)
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showHelperPointController" {
      if let vc = segue.destinationViewController as? HelperPointViewController {
        delegate?.togglePaused(true)
        vc.delegate = delegate
        helperPointController = vc
        vc.gameViewController = self
      }
    }
    
    if segue.identifier == "showTutorialSegue" {
      if let vc = segue.destinationViewController as? HelperHelpViewController {
        vc.delegate = delegate
        vc.gameViewController = self
      }
    }
  }
  
  
  
  
  
}
