//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

typealias Coordinates = (x: CGFloat, y: CGFloat)
typealias GridCoordinates = (x: Int, y: Int)

class ViewController: UIViewController {

  @IBOutlet weak var topScoreLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  var gameView: UIView?
  var tileViews: Array<UIView> = []
  //NOTE: ALL TILES START AT 0 INSTEAD OF ONE DONT GET CONFUSED
  var tileCoordinates: Array<GridCoordinates> = [(x:0, y:0), (x:1, y:0), (x:2, y:0), (x:0, y:1), (x:1, y:1), (x:2, y:1), (x:0, y:2), (x:1, y:2), (x:2, y:2)]
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  var middleLocs: Array<CGPoint> = []
  var viewWidth: CGFloat = 0
  var gameViewWidth: CGFloat = 0
  var tileWidth: CGFloat = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewWidth = self.view.frame.width
    configureGameView()
  }
  
  func configureGameView() {
    let offset = (viewWidth - (viewWidth / 1.25)) / 2
    gameView = UIView(frame: CGRectMake(offset, 210, viewWidth / 1.25, viewWidth / 1.25))
    gameViewWidth = gameView!.frame.width
    tileWidth = gameViewWidth / 3
    gameView?.backgroundColor = UIColor.darkGrayColor()
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
      let tileView = UIView(frame: CGRectMake(coords.x, coords.y, tileWidth, tileWidth))
      tileView.backgroundColor = UIColor.cyanColor()
      tileViews.append(tileView)
      adjustCoords(i)
      gameView.addSubview(tileView)
    }
    
  }
  
  //first find the tiles in the array based on the coordinates within the game view began and ended on. Have  tuple with the number of tilewidths horizontal and vertical then each tile has a set of tupels that it corresponds to
  //then divide the x and ys to get the differences based on the gameview and find the middle
  
  func resolveUserInteraction() {

    if let startLoc = startLoc, endLoc = endLoc {
      var startTile: UIView?
      var endTile: UIView?
      //Int floors the cgfloat
      let start = (x: Int(startLoc.x / tileWidth), y: Int(startLoc.y / tileWidth))
      print("START: \(start.x), \(start.y)")
      let end = (x: Int(endLoc.x / tileWidth), y: Int(endLoc.y / tileWidth))
      print("END: \(end.x), \(end.y)")
      
      for var i = 0; i < tileCoordinates.count; i++ {
        let loc = tileCoordinates[i]
        if loc.x == start.x && loc.y == start.y {
          startTile = tileViews[i]
          print("START TILE FOUND: \(i)")
        }
        if loc.x == end.x && loc.y == end.y {
          endTile = tileViews[i]
          print("END TILE FOUND: \(i)")
        }
      }
      
      if let startTile = startTile, endTile = endTile {
        tileRespond(startTile, endTile: endTile)
        self.startLoc = nil
        self.endLoc = nil
      }
    }
  }
  
  func tileRespond(startTile: UIView, endTile: UIView) {
    print("TILE RESPOND TIME")
    startTile.backgroundColor = UIColor.redColor()
    endTile.backgroundColor = UIColor.redColor()
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


}

