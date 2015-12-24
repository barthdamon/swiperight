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
  
  var currentLayout: GridNumberLayout? {
    didSet {
      self.delegate.resetClientOperations(currentLayout?.operations)
    }
  }
  var nextLayout: GridNumberLayout?
  
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
    let swipeRecognizer = UIPanGestureRecognizer(target: self, action: "gameViewSwiped:")
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
    
    for var i = 0; i < 9; i++ {
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
        
        for var i = 0; i < Grid.tileCoordinates.count; i++ {
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
  
  func tileRespond(startTile: TileView, middleTile: TileView, endTile: TileView) {
    
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
    
    if GameStatus.status.gameActive {
      print("TILE RESPOND TIME")
      if let operations = currentLayout?.operations, startNumber = startTile.number, midNumber = middleTile.number, endNumber = endTile.number {
        if checkForCorrect(operations, start: startNumber, mid: midNumber, end: endNumber) {
          delegate.scoreChange(true)
          startTile.backgroundColor = UIColor.greenColor()
          endTile.backgroundColor = UIColor.greenColor()
          middleTile.backgroundColor = UIColor.greenColor()
          self.userInteractionEnabled = false
          resetTiles()
        } else {
          delegate.scoreChange(false)
          startTile.backgroundColor = UIColor.redColor()
          endTile.backgroundColor = UIColor.redColor()
          middleTile.backgroundColor = UIColor.redColor()
          self.userInteractionEnabled = false
          resetTiles()
        }
      }
    }
  }
  
  func resetTiles() {
    if GameStatus.status.gameActive {
      if let nextLayout = self.nextLayout {
        self.currentLayout = nextLayout
        self.nextLayout = GridNumberLayout()
      } else {
        self.currentLayout = GridNumberLayout()
        //in the future generate next layout asynchronously in thebackground after current layout is generated
        self.nextLayout = GridNumberLayout()
      }
      animateTileReset()
    }
  }
  
  func animateTileReset() {
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
    
    tileViews.forEach { (tile) -> () in
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        tile.backgroundColor = UIColor.clearColor()
        tile.numberLabel?.alpha = 0
        }, completion: { (complete) -> Void in
          self.applyNumberLayoutToTiles(false)
          fadeInTiles()
      })
    }
  }
  
  func applyNumberLayoutToTiles(reset: Bool) {
    if let layout = currentLayout {
      for var i = 0; i < layout.numbers.count; i++ {
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
  
  func gameOver(score: Int) {
    self.applyNumberLayoutToTiles(true)
    let yCoord = tileWidth / 2
    gameOverView = UIView(frame: CGRectMake(0,0, self.frame.width, self.frame.height))
    gameOverView?.backgroundColor = UIColor.clearColor()

    let gameOverLabel = UILabel(frame: CGRectMake(0,yCoord,tileWidth * 3, 50))
    gameOverLabel.text = "Game Over"
    gameOverLabel.font = UIFont.systemFontOfSize(30)
    gameOverLabel.textAlignment = .Center
    gameOverLabel.textColor = UIColor.whiteColor()
    
    
    let scoreLabel = UILabel(frame: CGRectMake(0,yCoord + 50,tileWidth * 3, 50))
    scoreLabel.text = "Your Score: \(score)"
    scoreLabel.textColor = UIColor.whiteColor()
    scoreLabel.textAlignment = .Center
    
    //add top score label or w/e
    gameOverView?.addSubview(gameOverLabel)
    gameOverView?.addSubview(scoreLabel)
    self.addSubview(gameOverView!)
    delegate.toggleClientView()
  }
  
}
