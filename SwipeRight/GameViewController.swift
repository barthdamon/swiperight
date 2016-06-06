//
//  GameViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
  
  var gameLaunchController: GameLaunchViewController?
  var helperPointController: HelperPointViewController?
  var delegate: GameViewDelegate?
  
  var gradientLayer: CAGradientLayer?
  var tileWidth: CGFloat!
  var viewWidth: CGFloat!
  var tileViews: Array<TileView> = []
  var intermissionTimer: NSTimer = NSTimer()
  
  var gameOverView: UIView?
  var roundOverView: UIView?
  var helperView: UIView?
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  
  var hideButton: UIButton?
  var removeButton: UIButton?
  var revealButton: UIButton?
  
  var modOne: Modification?
  var modTwo: Modification?
  var modOneButton: UIButton?
  var modTwoButton: UIButton?
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
    self.viewWidth = delegate?.getWidth()
    tileWidth = self.view.frame.width / 3
    self.view.backgroundColor = ThemeHelper.defaultHelper.sw_gameview_background_color
    self.view.userInteractionEnabled = false
    configureGameViewComponents()
    animateBeginGame()
  }
  
  func configureGameViewComponents() {
    
    var coords = Coordinates(x: 0, y: 0)
    
    func adjustCoords(i: Int) {
      coords.x = coords.x + tileWidth
      if i == 2 || i == 5  {
        coords.x = 0
        coords.y = coords.y + tileWidth
      }
    }
    
    for i in 0 ..< 9 {
      let tileView = TileView(xCoord: coords.x, yCoord: coords.y, tileWidth: tileWidth, overlay: false)
      tileViews.append(tileView)
      adjustCoords(i)
      self.view.addSubview(tileView)
    }
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
    if GameStatus.status.gameActive {
      print("TILE RESPOND TIME")
      if let operations = currentLayout?.operations, startNumber = startTile.number, midNumber = middleTile.number, endNumber = endTile.number {
        if checkForCorrect(operations, start: startNumber, mid: midNumber, end: endNumber) {
          delegate?.scoreChange(true)
          startTile.backgroundColor = UIColor.greenColor()
          endTile.backgroundColor = UIColor.greenColor()
          middleTile.backgroundColor = UIColor.greenColor()
          self.view.userInteractionEnabled = false
          delegate?.addTime(ProgressionManager.sharedManager.standardBoostTime)
        } else {
          delegate?.scoreChange(false)
          startTile.backgroundColor = UIColor.redColor()
          endTile.backgroundColor = UIColor.redColor()
          middleTile.backgroundColor = UIColor.redColor()
          self.view.userInteractionEnabled = false
        }
        ProgressionManager.sharedManager.currentRoundPosition += 1
        if ProgressionManager.sharedManager.currentRoundPosition > ProgressionManager.sharedManager.roundLength {
          newRound()
        }
        resetTiles()
      }
    }
  }
  
  func resetTiles() {
    if GameStatus.status.gameActive {
      self.currentLayout = GridNumberLayout()
      self.gradientLayer?.removeFromSuperlayer()
      guard let layout = currentLayout else { return }
      var color: UIColor = UIColor.darkGrayColor()
      if layout.operations.count == 1 {
        color = layout.operations[0].color
        self.view.backgroundColor = color
      } else {
        let firstOperation = layout.operations.filter({if $0 == .Add || $0 == .Subtract {
          return true
        } else {
          return false
          }})
        let firstColor = firstOperation[0].color
        let secondOperation = layout.operations.filter({$0 == .Multiply || $0 == .Divide})
        let secondColor = secondOperation[0].color
        gradientLayer = CAGradientLayer.gradientLayerForBounds(self.view.bounds, colors: (start: firstColor, end: secondColor))
        self.view.layer.hidden = false
        self.view.layer.insertSublayer(gradientLayer!, atIndex: 0)
        // half and half
      }
      animateTileReset()
    }
  }
  
  func fadeOutTiles(callback: (complete: Bool) -> ()) {
    for (i, tile) in tileViews.enumerate() {
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        tile.backgroundColor = UIColor.clearColor()
        tile.numberLabel?.alpha = 0
        tile.layer.borderWidth = 0
        }, completion: { (complete) -> Void in
          if i == self.tileViews.count - 1 {
            callback(complete: true)
          }
      })
    }
  }
  
  func fadeInTiles() {
    tileViews.forEach { (tile) -> () in
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        tile.numberLabel?.alpha = tile.number == -1 ? 0 : 1
        tile.layer.borderWidth = 1
        }, completion: { (complete) -> Void in
          self.view.userInteractionEnabled = true
          self.delegate?.beginGame()
      })
    }
  }
  
  func animateTileReset() {
    fadeOutTiles { (complete) in
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
    let coords = Coordinates(x: 0, y: 0)
    let overlayView = TileView(xCoord: coords.x + tileWidth, yCoord: coords.y + tileWidth, tileWidth: tileWidth, overlay: true)
    self.view.addSubview(overlayView)
    gameOverView?.removeFromSuperview()
    gameOverView = nil
    overlayView.animateCountdown() { (res) in
      if res {
        self.delegate?.setStartTime()
        overlayView.removeFromSuperview()
        GameStatus.status.gameActive = true
        self.resetTiles()
        self.delegate?.startGameplay()
        self.delegate?.toggleClientView()
      }
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
    ProgressionManager.sharedManager.helperPointsForNewRound()
  }
  
  
  
  
  
  //MARK: Helpers
  func configureHelperOptionUI() {
//    helperView = UIView(frame: CGRectMake(0,0,self.view.frame.width, self.view.frame.height))
//    let buttonWidth = (viewWidth / 1.25) / 3
//    hideButton = UIButton(frame: CGRectMake(0,0,buttonWidth, 20))
//    hideButton?.setTitle("Hide", forState: .Normal)
//    hideButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//    hideButton?.backgroundColor = UIColor.darkGrayColor()
//    hideButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//    hideButton?.enabled = false
//    
//    removeButton = UIButton(frame: CGRectMake(buttonWidth,0,buttonWidth, 20))
//    removeButton?.setTitle("Remove", forState: .Normal)
//    removeButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//    removeButton?.backgroundColor = UIColor.darkGrayColor()
//    removeButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//    removeButton?.enabled = false
//    
//    revealButton = UIButton(frame: CGRectMake(buttonWidth * 2,0,buttonWidth, 20))
//    revealButton?.setTitle("Reveal", forState: .Normal)
//    revealButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//    revealButton?.backgroundColor = UIColor.darkGrayColor()
//    revealButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//    revealButton?.enabled = false
//    
//    helperView?.addSubview(hideButton!)
//    helperView?.addSubview(removeButton!)
//    helperView?.addSubview(revealButton!)
  }
  
  func setHelperButtons() {
    let points = ProgressionManager.sharedManager.currentHelperPoints
    guard let layout = currentLayout, _ = layout.winningCombination else { return }
    delegate?.setHelperPoints(points)
    // need to know the index of all of th
    let showRemove = points >= 2
    let showHide = points >= 1
    let showReveal = points >= 3
    // need the active operation of the current solution and all of the number indexes
    if showRemove && ProgressionManager.sharedManager.multipleOperationsDisplayActive  {
      removeButton?.enabled = true
      removeButton?.backgroundColor = .lightGrayColor()
    } else {
      removeButton?.enabled = false
      removeButton?.backgroundColor = .darkGrayColor()
    }
    
    if showHide && ProgressionManager.sharedManager.numberOfExtraTiles > 0 {
      hideButton?.enabled = true
      hideButton?.backgroundColor = .lightGrayColor()
    } else {
      hideButton?.enabled = false
      hideButton?.backgroundColor = .darkGrayColor()
    }
    
    if showReveal {
      revealButton?.enabled = true
      revealButton?.backgroundColor = .lightGrayColor()
    } else {
      revealButton?.enabled = false
      revealButton?.backgroundColor = .darkGrayColor()
    }
  }
  
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
      possibleRemovals[randRemovalIndex].backgroundColor = UIColor.redColor()
      ProgressionManager.sharedManager.helperPointUtilized(.Hide)
    case .Reveal:
      let randIndex = Int.random(0...2)
      let randSolutionIndex = indexes[randIndex]
      // reveal one
      self.tileViews[randSolutionIndex].backgroundColor = UIColor.greenColor()
      // light up a tile selected
      ProgressionManager.sharedManager.helperPointUtilized(.Reveal)
    case .Remove:
      let filteredOperations = ProgressionManager.sharedManager.activeOperations.filter({$0 == combo.operation})
      delegate?.resetClientOperations(filteredOperations)
      ProgressionManager.sharedManager.helperPointUtilized(.Remove)
    }
  }
  
  func helperButtonPressed() {
    self.performSegueWithIdentifier("showHelperPointController", sender: self)
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showHelperPointController" {
      if let vc = segue.destinationViewController as? HelperPointViewController {
        vc.delegate = delegate
        helperPointController = vc
        vc.gameViewController = self
      }
    }
  }
  
  
  
  
  
}
