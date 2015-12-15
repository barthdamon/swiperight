//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameViewDelegate {

  @IBOutlet weak var beginButton: NSLayoutConstraint!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  var gameView: GameView?
  var countdownOverlayView: TileView?
  var viewWidth: CGFloat = 0
  
  var gameDuration = 10
  var timer: NSTimer?
  var gameActive: Bool = false
  
  var time: Int = 0 {
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
    gameView = GameView(viewWidth: viewWidth, delegate: self)
    self.view.addSubview(gameView!)
  }
  
  
  //MARK: GameView Delegate Methods:
  
  func scoreChange(correct: Bool) {
    if correct {
      score++
    } else {
      score--
    }
  }
  
  func beginGame() {
    if !gameActive {
      gameView?.animateBeginGame()
    }
  }
  
  func startGameplay() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tickTock", userInfo: nil, repeats: true)
      self.gameActive = true
    })
  }
  
  func resetGameState() {
    score = 0
    time = gameDuration
    gameView?.applyNumberLayoutToTiles(true)
    gameActive = false
  }
  
  
  //MARK: HUD
  func configureHUD() {
    resetGameState()
  }
  
  func tickTock() {
    if gameActive {
      time--
      if time == 0 {
        gameOver()
      }
    }
  }
  
  func gameOver() {
    timer?.invalidate()
    timer = nil
    self.gameView?.userInteractionEnabled = false
    self.alertShow("Game Over", alertMessage: "Your Score: \(String(score))")
  }

  func alertShow(alertText :String, alertMessage :String) {
    let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "AGAIN!", style: .Default, handler: { (action) -> Void in
      self.dismissViewControllerAnimated(true, completion: nil)
      self.resetGameState()
      self.beginGame()
    }))
    alert.addAction(UIAlertAction(title: "Please, no more", style: .Default, handler: { (action) -> Void in
      self.dismissViewControllerAnimated(true, completion: nil)
      self.resetGameState()
    }))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  
  
  @IBAction func beginButtonPressed(sender: AnyObject) {
    resetGameState()
    beginGame()
  }
  
}

