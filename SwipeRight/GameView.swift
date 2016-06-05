//
//  GameView.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

protocol GameViewDelegate {
  func beginGame()
  func scoreChange(correct: Bool)
  func startGameplay()
  func resetGameState()
  func setStartTime()
  func configureStartOptions()
  func toggleClientView()
  func resetClientOperations(currentOperations: Array<Operation>?)
  func addTime(seconds: Int)
  func gameOver(finished: Bool)
  func setRound(number: Int)
  func setHelperButtons()
  func getWidth() -> CGFloat
}

class GameView: UIView, UIGestureRecognizerDelegate {
  
  var container: UIView?
  
  var gradientLayer: CAGradientLayer?
  var delegate: GameViewDelegate!
  var tileWidth: CGFloat!
  var viewWidth: CGFloat!
  var tileViews: Array<TileView> = []
  var intermissionTimer: NSTimer = NSTimer()
  
  var gameOverView: UIView?
  var roundOverView: UIView?
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  
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
      self.delegate.resetClientOperations(currentLayout?.operations)
    }
  }
  
  convenience init(container: UIView, delegate: GameViewDelegate) {
    self.init()
    self.container = container
    self.viewWidth = delegate.getWidth()
    self.delegate = delegate
    self.frame = container.bounds
    // KEEP return this as var: gameViewWidth = gameView!.frame.width
    //also need tileWidth to be a var based off this view
    tileWidth = delegate.getWidth() / 3
    self.backgroundColor = ThemeHelper.defaultHelper.sw_gameview_background_color
    self.userInteractionEnabled = false
    configureGameViewComponents()
    container.addSubview(self)
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
      self.addSubview(tileView)
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    startLoc = touch.locationInView(self)
    print("Touches began")
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    let end = touch.locationInView(self)
    if (end.x > 0 && end.y > 0) && (end.x < self.frame.width && end.y < self.frame.height) {
      endLoc = touch.locationInView(self)
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    let end = touch.locationInView(self)
    if (end.x > 0 && end.y > 0) && (end.x < self.frame.width && end.y < self.frame.height) {
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
          delegate.scoreChange(true)
          startTile.backgroundColor = UIColor.greenColor()
          endTile.backgroundColor = UIColor.greenColor()
          middleTile.backgroundColor = UIColor.greenColor()
          self.userInteractionEnabled = false
          delegate?.addTime(ProgressionManager.sharedManager.standardBoostTime)
        } else {
          delegate.scoreChange(false)
          startTile.backgroundColor = UIColor.redColor()
          endTile.backgroundColor = UIColor.redColor()
          middleTile.backgroundColor = UIColor.redColor()
          self.userInteractionEnabled = false
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
        self.backgroundColor = color
      } else {
        let firstOperation = layout.operations.filter({if $0 == .Add || $0 == .Subtract {
          return true
        } else {
          return false
        }})
        let firstColor = firstOperation[0].color
        let secondOperation = layout.operations.filter({$0 == .Multiply || $0 == .Divide})
        let secondColor = secondOperation[0].color
        gradientLayer = CAGradientLayer.gradientLayerForBounds(self.bounds, colors: (start: firstColor, end: secondColor))
        self.layer.hidden = false
        self.layer.insertSublayer(gradientLayer!, atIndex: 0)
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
          self.userInteractionEnabled = true
          self.delegate.beginGame()
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
    self.addSubview(overlayView)
    gameOverView?.removeFromSuperview()
    gameOverView = nil
    overlayView.animateCountdown() { (res) in
      if res {
        self.delegate?.setStartTime()
        overlayView.removeFromSuperview()
        GameStatus.status.gameActive = true
        self.resetTiles()
        self.delegate.startGameplay()
        self.delegate.toggleClientView()
      }
    }
  }
  
  func helperSelected(helperPoint: HelperPoint) {
    guard let layout = self.currentLayout, indexes = layout.solutionIndexes else { return }
    ProgressionManager.sharedManager.helperPointUtilized(helperPoint)
    switch helperPoint {
    case .Remove:
      // remove dealt with on view controller
      break
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
    case .Reveal:
      let randIndex = Int.random(0...2)
      let randSolutionIndex = indexes[randIndex]
      // reveal one
      self.tileViews[randSolutionIndex].backgroundColor = UIColor.greenColor()
    }
  }
  
  func gameOver(score: Int) {
    self.fadeOutTiles { (complete) in
      self.backgroundColor = ThemeHelper.defaultHelper.sw_gameview_background_color
      self.gradientLayer?.removeFromSuperlayer()
      let yCoord = self.tileWidth / 2
      self.gameOverView = UIView(frame: CGRectMake(0,0, self.frame.width, self.frame.height))
      self.gameOverView?.backgroundColor = UIColor.clearColor()
      
      let gameOverLabel = UILabel(frame: CGRectMake(0,yCoord,self.tileWidth * 3, 50))
      gameOverLabel.text = "Game Over"
      gameOverLabel.font = ThemeHelper.defaultHelper.sw_font_large
      gameOverLabel.textAlignment = .Center
      gameOverLabel.textColor = UIColor.blackColor()
      
      let scoreLabel = UILabel(frame: CGRectMake(0,yCoord + 50,self.tileWidth * 3, 50))
      scoreLabel.text = "Your Score: \(score)"
      scoreLabel.font = ThemeHelper.defaultHelper.sw_font
      scoreLabel.textColor = UIColor.blackColor()
      scoreLabel.textAlignment = .Center
      
      //add top score label or w/e
      self.gameOverView?.addSubview(gameOverLabel)
      self.gameOverView?.addSubview(scoreLabel)
      self.addSubview(self.gameOverView!)
      self.delegate.toggleClientView()
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
    self.delegate?.setHelperButtons()
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  //MARK: OLD ROUND CODE
//  func resetRound() {
//    self.intermissionTimer.invalidate()
//    self.roundOverView?.removeFromSuperview()
//    gameOverView?.removeFromSuperview()
//    self.gameOverView = nil
//    self.delegate?.setStartTime()
//    self.delegate?.setRound(ProgressionManager.sharedManager.currentRound)
//    resetTiles()
//  }
//  
//  func newRoundOld() {
//    self.backgroundColor = UIColor.darkGrayColor()
//    self.fadeOutTiles { (complete) in
//      ProgressionManager.sharedManager.helperPointsForNewRound()
//      ProgressionManager.sharedManager.currentRound += 1
//      ProgressionManager.sharedManager.currentRoundPosition = 1
//      self.delegate?.setHelperButtons()
//      let yCoord = self.tileWidth / 2
//      self.roundOverView = UIView(frame: CGRectMake(0,0, self.frame.width, self.frame.height))
//      self.roundOverView?.backgroundColor = UIColor.clearColor()
//      self.roundOverView?.userInteractionEnabled = true
//      
//      let roundOverLabel = UILabel(frame: CGRectMake(0,yCoord,self.tileWidth * 3, 50))
//      roundOverLabel.text = "Level \(ProgressionManager.sharedManager.currentRound)"
//      roundOverLabel.font = UIFont.systemFontOfSize(30)
//      roundOverLabel.textAlignment = .Center
//      roundOverLabel.textColor = UIColor.whiteColor()
//      
//      
//      let scoreLabel = UILabel(frame: CGRectMake(0,yCoord + 50,self.tileWidth * 3, 50))
//      scoreLabel.text = "Pick A Difficulty Modification:"
//      scoreLabel.textColor = UIColor.whiteColor()
//      scoreLabel.textAlignment = .Center
//      
//      self.intermissionTimeLabel = UILabel(frame: CGRectMake(0,yCoord + 225,self.tileWidth * 3, 50))
//      self.intermissionTimeLabel!.text = "Next Round Starts: 5"
//      self.intermissionTimeLabel!.textColor = UIColor.whiteColor()
//      self.intermissionTimeLabel!.textAlignment = .Center
//      
//      let modifications = ProgressionManager.sharedManager.generateRoundModifications()
//      guard modifications.count == 2 else { return }
//      self.modOne = modifications[0]
//      self.modTwo = modifications[1]
//      guard let modOne = self.modOne, modTwo = self.modTwo else { return }
//      
//      self.modOneButton = UIButton(frame: CGRectMake(0,yCoord + 100,self.tileWidth * 3, 50))
//      self.modOneButton!.setTitle("\(modOne.type.rawValue) (\(modOne.remaining))", forState: .Normal)
//      self.modOneButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//      self.modOneButton!.backgroundColor = UIColor.blackColor()
//      self.modOneButton!.titleLabel?.font = UIFont.systemFontOfSize(30)
//      self.modOneButton!.addTarget(self, action: #selector(GameView.modOneButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//      
//      self.modTwoButton = UIButton(frame: CGRectMake(0,yCoord + 175,self.tileWidth * 3, 50))
//      self.modTwoButton!.setTitle("\(modTwo.type.rawValue) (\(modTwo.remaining))", forState: .Normal)
//      self.modTwoButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//      self.modTwoButton!.backgroundColor = UIColor.blackColor()
//      self.modTwoButton!.titleLabel?.font = UIFont.systemFontOfSize(30)
//      
//      self.modTwoButton!.addTarget(self, action: #selector(GameView.modTwoButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//      
//      //add top score label or w/e
//      self.intermissionTime = 20
//      self.intermissionTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameView.intermissionTickTock), userInfo: nil, repeats: true)
//      self.roundOverView?.addSubview(roundOverLabel)
//      self.roundOverView?.addSubview(scoreLabel)
//      self.roundOverView?.addSubview(self.intermissionTimeLabel!)
//      self.roundOverView?.addSubview(self.modOneButton!)
//      self.roundOverView?.addSubview(self.modTwoButton!)
//      self.addSubview(self.roundOverView!)
//      self.userInteractionEnabled = true
//      //      self.delegate.toggleClientView()
//    }
//  }
//  
//  
//  func intermissionTickTock() {
//    intermissionTime -= 1
//    if intermissionTime == 0 {
//      delegate?.gameOver(true)
//    }
//  }
//  
//  func modOneButtonPressed(button: UIButton) {
//    if let modOne = modOne {
//      ProgressionManager.sharedManager.newModificationSelected(modOne)
//      GameStatus.status.gameActive = true
//      resetRound()
//      self.delegate?.setHelperButtons()
//    }
//  }
//  
//  func modTwoButtonPressed(button: UIButton) {
//    if let modTwo = modTwo {
//      ProgressionManager.sharedManager.newModificationSelected(modTwo)
//      GameStatus.status.gameActive = true
//      resetRound()
//      self.delegate?.setHelperButtons()
//    }
//  }
  
  
}

