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
  func configureStartOptions()
  func toggleClientView()
  func resetClientOperations(currentOperations: Array<Operation>?)
  func addTime(seconds: Int)
}

class GameView: UIView {
  
  var delegate: GameViewDelegate!
  var tileWidth: CGFloat!
  var viewWidth: CGFloat!
  var tileViews: Array<TileView> = []
  
  //gameOver
  var gameOverView: UIView?
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  
  var modOne: Modification?
  var modTwo: Modification?
  
  var currentLayout: GridNumberLayout? {
    didSet {
      self.delegate.resetClientOperations(currentLayout?.operations)
    }
  }
  
  convenience init(viewWidth: CGFloat, viewHeight: CGFloat, delegate: GameViewDelegate) {
    self.init()
    self.viewWidth = viewWidth
    self.delegate = delegate
    
    let offset = (viewWidth - (viewWidth / 1.25)) / 2
    self.frame = CGRectMake(offset, viewHeight / 2.5, viewWidth / 1.25, viewWidth / 1.25)
    // KEEP return this as var: gameViewWidth = gameView!.frame.width
    //also need tileWidth to be a var based off this view
    tileWidth = self.frame.width / 3
    self.backgroundColor = UIColor.darkGrayColor()
    self.userInteractionEnabled = false
    addGestureRecognizers()
    configureGameViewComponents()
  }

  func addGestureRecognizers() {
    let swipeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameView.gameViewSwiped(_:)))
    swipeRecognizer.minimumNumberOfTouches = 1
    self.addGestureRecognizer(swipeRecognizer)
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
  
  func gameViewSwiped(sender: UIGestureRecognizer) {
    let loc = sender.locationInView(self)
    if sender.state == .Began {
      startLoc = loc
      print("Gesture Began: \(loc)")
      resolveUserInteraction()
    }
    if sender.state == .Ended {
      endLoc = loc
      print("Gesture Ended \(loc)")
      resolveUserInteraction()
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
        
        if ProgressionManager.sharedManager.currentRoundPosition == ProgressionManager.sharedManager.roundLength {
          // show round options, then start new round
          GameStatus.status.gameActive = false
          newRound()
        } else {
          ProgressionManager.sharedManager.currentRoundPosition += 1
          resetTiles()
        }
      }
    }
  }
  
  func resetTiles() {
    if GameStatus.status.gameActive {
      self.currentLayout = GridNumberLayout()
      animateTileReset()
    }
  }
  
  func fadeOutTiles(callback: (complete: Bool) -> ()) {
    for (i, tile) in tileViews.enumerate() {
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        tile.backgroundColor = UIColor.clearColor()
        tile.numberLabel?.alpha = 0
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
        tile.numberLabel?.alpha = 1
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
          tileViews[i].numberLabel?.alpha = 1
          tileViews[i].number = layout.numbers[i]
        }
      }
    }
  }
  
  func animateBeginGame() {
    let coords = Coordinates(x: 0, y: 0)
    let overlayView = TileView(xCoord: coords.x + tileWidth, yCoord: coords.y + tileWidth, tileWidth: tileWidth, overlay: true)
    self.addSubview(overlayView)
    overlayView.animateCountdown() { (res) in
      if res {
        overlayView.removeFromSuperview()
        GameStatus.status.gameActive = true
        self.resetTiles()
        self.delegate.startGameplay()
        self.delegate.toggleClientView()
      }
    }
  }
  
  func newRound() {
    self.fadeOutTiles { (complete) in
      ProgressionManager.sharedManager.currentRound += 1
      let yCoord = self.tileWidth / 2
      self.gameOverView = UIView(frame: CGRectMake(0,0, self.frame.width, self.frame.height))
      self.gameOverView?.backgroundColor = UIColor.clearColor()
      
      let roundOverLabel = UILabel(frame: CGRectMake(0,yCoord,self.tileWidth * 3, 50))
      roundOverLabel.text = "Round \(ProgressionManager.sharedManager.currentRound)"
      roundOverLabel.font = UIFont.systemFontOfSize(30)
      roundOverLabel.textAlignment = .Center
      roundOverLabel.textColor = UIColor.whiteColor()
      
      
      let scoreLabel = UILabel(frame: CGRectMake(0,yCoord + 50,self.tileWidth * 3, 50))
      scoreLabel.text = "Pick A Difficulty Modification:"
      scoreLabel.textColor = UIColor.whiteColor()
      scoreLabel.textAlignment = .Center
      
      let modifications = ProgressionManager.sharedManager.generateRoundModifications()
      guard modifications.count == 2 else { return }
      self.modOne = modifications[0]
      self.modTwo = modifications[1]
      guard let modOne = self.modOne, modTwo = self.modTwo else { return }
      
      let modOneButton = UIButton(frame: CGRectMake(0,yCoord + 100,self.tileWidth * 3, 50))
      modOneButton.setTitle("\(modOne.type.rawValue) (\(modOne.remaining)", forState: .Normal)
      modOneButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      modOneButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
      modOneButton.setTitleColor(UIColor.darkGrayColor(), forState: .Highlighted)
      modOneButton.titleLabel?.font = UIFont.systemFontOfSize(30)
      modOneButton.addTarget(self, action: #selector(GameView.modOneButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
      
      let modTwoButton = UIButton(frame: CGRectMake(0,yCoord + 150,self.tileWidth * 3, 50))
      modTwoButton.setTitle("\(modTwo.type.rawValue) (\(modTwo.remaining)", forState: .Normal)
      modTwoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      modTwoButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
      modTwoButton.setTitleColor(UIColor.darkGrayColor(), forState: .Highlighted)
      modTwoButton.titleLabel?.font = UIFont.systemFontOfSize(30)
      modTwoButton.addTarget(self, action: #selector(GameView.modTwoButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
      
//      let modOneLabel = UIButton(frame: CGRectMake(0,yCoord + 100,self.tileWidth * 3, 50))
//      modOneLabel.text = "\(modOne.type.rawValue) (\(modOne.remaining))"
//      modOneLabel.textColor = UIColor.whiteColor()
//      modOneLabel.textAlignment = .Center
//
//      let modTwoLabel = UILabel(frame: CGRectMake(0,yCoord + 150,self.tileWidth * 4, 50))
//      modTwoLabel.text = "\(modTwo.type.rawValue) (\(modTwo.remaining))"
//      modTwoLabel.textColor = UIColor.whiteColor()
//      modTwoLabel.textAlignment = .Center
      
      //add top score label or w/e
      self.gameOverView?.addSubview(roundOverLabel)
      self.gameOverView?.addSubview(scoreLabel)
      self.gameOverView?.addSubview(modOneButton)
      self.gameOverView?.addSubview(modTwoButton)
      self.addSubview(self.gameOverView!)
      self.delegate.toggleClientView()
    }
  }
  
  func modOneButtonPressed() {
    if let modOne = modOne {
      ProgressionManager.sharedManager.newModificationSelected(modOne)
    }
  }
  
  func modTwoButtonPressed() {
    if let modTwo = modTwo {
      ProgressionManager.sharedManager.newModificationSelected(modTwo)
    }
  }
  
  func gameOver(score: Int) {
    self.fadeOutTiles { (complete) in
      let yCoord = self.tileWidth / 2
      self.gameOverView = UIView(frame: CGRectMake(0,0, self.frame.width, self.frame.height))
      self.gameOverView?.backgroundColor = UIColor.clearColor()
      
      let gameOverLabel = UILabel(frame: CGRectMake(0,yCoord,self.tileWidth * 3, 50))
      gameOverLabel.text = "Game Over"
      gameOverLabel.font = UIFont.systemFontOfSize(30)
      gameOverLabel.textAlignment = .Center
      gameOverLabel.textColor = UIColor.whiteColor()
      
      
      let scoreLabel = UILabel(frame: CGRectMake(0,yCoord + 50,self.tileWidth * 3, 50))
      scoreLabel.text = "Your Score: \(score)"
      scoreLabel.textColor = UIColor.whiteColor()
      scoreLabel.textAlignment = .Center
      
      //add top score label or w/e
      self.gameOverView?.addSubview(gameOverLabel)
      self.gameOverView?.addSubview(scoreLabel)
      self.addSubview(self.gameOverView!)
      self.delegate.toggleClientView()
    }
  }
  
}

