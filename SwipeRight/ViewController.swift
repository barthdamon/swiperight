//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

struct Coordinates {
  var x: CGFloat!
  var y: CGFloat!
}

class ViewController: UIViewController {

  @IBOutlet weak var topScoreLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  var gameView: UIView?
  var tileViews: Array<UIView> = []
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  var width: CGFloat = 0
  var gameViewWidth: CGFloat = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    width = self.view.frame.width
    configureGameView()
  }
  
  func configureGameView() {
    let offset = (width - (width / 1.25)) / 2
    gameView = UIView(frame: CGRectMake(offset, 210, width / 1.25, width / 1.25))
    gameViewWidth = gameView!.frame.width
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
    let width = gameViewWidth / 3
    
    func adjustCoords(i: Int) {
      coords.x = coords.x + width
      if i == 2 || i == 5  {
        coords.x = 0
        coords.y = coords.y + width
      }
    }
    
    for var i = 0; i < 9; i++ {
      let tileView = UIView(frame: CGRectMake(coords.x, coords.y, width, width))
      tileView.backgroundColor = UIColor.cyanColor()
      tileViews.append(tileView)
      adjustCoords(i)
      gameView.addSubview(tileView)
    }
    
  }
  
  func resolveUserInteraction() {
    if let startLoc = startLoc, endLoc = endLoc {
      var startTile: UIView?
      var endTile: UIView?
      
      
//      tileViews.forEach({ (view) -> () in
//        if startLoc.x > view.frame
//      })
    }
  }
  
  func gameViewSwiped(sender: UIGestureRecognizer) {
    let loc = sender.locationInView(gameView)
    if sender.state == .Began {
      startLoc = loc
      print("Gesture Began: \(loc)")
    }
    if sender.state == .Ended {
      endLoc = loc
      print("Gesture Ended \(loc)")
    }
    resolveUserInteraction()
  }


}

