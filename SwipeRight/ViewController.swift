//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var beginButton: NSLayoutConstraint!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  var gameView: UIView?
  var tileViews: Array<TileView> = []

  var currentLayout: GridNumberLayout?
  var nextLayout: GridNumberLayout?
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  var middleLocs: Array<CGPoint> = []
  var viewWidth: CGFloat = 0
  var gameViewWidth: CGFloat = 0
  var tileWidth: CGFloat = 0
  
  var timer = NSTimer()
  var time: Int = 60 {
    didSet {
      timeLabel.text = String(time)
    }
  }
  var score: Int = 0 {
    didSet {
      scoreLabel.text = String(score)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewWidth = self.view.frame.width
    configureHUD()
    configureGameView()
  }
  
  
  //MARK: HUD
  func configureHUD() {
    resetGameState()
  }
  
  func resetGameState() {
    score = 0
    time = 60
    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tickTock", userInfo: nil, repeats: true)
  }
  
  func tickTock() {
    time--
    if time == 0 {
      gameOver()
    }
  }
  
  func gameOver() {
    timer.invalidate()
    self.gameView?.userInteractionEnabled = false
    self.alertShow("Game Over", alertMessage: "Your Score: \(String(score))")
  }

  func alertShow(alertText :String, alertMessage :String) {
    let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "AGAIN!", style: .Default, handler: { (action) -> Void in
      self.dismissViewControllerAnimated(true, completion: nil)
      self.resetGameState()
      self.resetTiles()
    }))
    alert.addAction(UIAlertAction(title: "Please, no more", style: .Default, handler: { (action) -> Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    }))
    self.presentViewController(alert, animated: true, completion: nil)
  }

  //MARK: TILE FUNCTIONALITY
  func configureGameView() {
    let offset = (viewWidth - (viewWidth / 1.25)) / 2
    gameView = UIView(frame: CGRectMake(offset, 210, viewWidth / 1.25, viewWidth / 1.25))
    gameViewWidth = gameView!.frame.width
    tileWidth = gameViewWidth / 3
    gameView?.backgroundColor = UIColor.darkGrayColor()
    gameView?.userInteractionEnabled = false
    self.view.addSubview(gameView!)
    addGestureRecognizers(gameView!)
    configureGameViewComponents(gameView!)
  }
  
  func addGestureRecognizers(gameView: UIView) {
    let swipeRecognizer = UIPanGestureRecognizer(target: self, action: "gameViewSwiped:")
    swipeRecognizer.minimumNumberOfTouches = 1
    gameView.addGestureRecognizer(swipeRecognizer)
  }
  
  func configureGameViewComponents(gameView: UIView) {
    var coords = Coordinates(x: 0, y: 0)
    
    func adjustCoords(i: Int) {
      coords.x = coords.x + tileWidth
      if i == 2 || i == 5  {
        coords.x = 0
        coords.y = coords.y + tileWidth
      }
    }
    
    for var i = 0; i < 9; i++ {
      let tileView = TileView(xCoord: coords.x, yCoord: coords.y, tileWidth: tileWidth)
      tileViews.append(tileView)
      adjustCoords(i)
      gameView.addSubview(tileView)
    }
  }
  
  func resolveUserInteraction() {
    if let startLoc = startLoc, endLoc = endLoc {
      var startTile: TileView?
      var endTile: TileView?
      var midTile: TileView?
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
        }
        if loc.x == end.x && loc.y == end.y {
          endTile = tileViews[i]
          print("END TILE FOUND: \(i)")
        }
        if loc.x == mid.x && loc.y == mid.y {
          midTile = tileViews[i]
          print("MID TILE FOUND: \(i)")
        }
      }
      
      if let startTile = startTile, midTile = midTile, endTile = endTile {
        tileRespond(startTile, middleTile: midTile, endTile: endTile)
        self.startLoc = nil
        self.endLoc = nil
      }
    }
  }
  
  func tileRespond(startTile: TileView, middleTile: TileView, endTile: TileView) {
    print("TILE RESPOND TIME")
    if let startNumber = startTile.number, midNumber = middleTile.number, endNumber = endTile.number {
      if startNumber + midNumber == endNumber {
        score++
        startTile.backgroundColor = UIColor.greenColor()
        endTile.backgroundColor = UIColor.greenColor()
        middleTile.backgroundColor = UIColor.greenColor()
        gameView?.userInteractionEnabled = false
        resetTiles()
      } else {
        score--
        startTile.backgroundColor = UIColor.redColor()
        endTile.backgroundColor = UIColor.redColor()
        middleTile.backgroundColor = UIColor.redColor()
        gameView?.userInteractionEnabled = false
        resetTiles()
      }
    }
  }
  
  func resetTiles() {
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
  
  func animateTileReset() {
    func fadeInTiles() {
      tileViews.forEach { (tile) -> () in
        UIView.animateWithDuration(1, animations: { () -> Void in
          tile.hidden = false
          }, completion: { (complete) -> Void in
            self.gameView?.userInteractionEnabled = true
        })
      }
    }
    
    tileViews.forEach { (tile) -> () in
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        tile.backgroundColor = UIColor.cyanColor()
        tile.hidden = true
        }, completion: { (complete) -> Void in
          self.applyNumberLayoutToTiles()
          fadeInTiles()
      })
    }
  }
  
  func applyNumberLayoutToTiles() {
    if let layout = currentLayout {
      for var i = 0; i < layout.numbers.count; i++ {
        tileViews[i].number = layout.numbers[i]
      }
    }
  }
  
  func gameViewSwiped(sender: UIGestureRecognizer) {
    let loc = sender.locationInView(gameView)
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
 
  @IBAction func beginButtonPressed(sender: AnyObject) {
    resetGameState()
    resetTiles()
  }
}

