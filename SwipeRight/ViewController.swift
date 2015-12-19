//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameViewDelegate {

  //HUD
  var scoreLabel: UILabel?
  var timeLabel: UILabel?
  var componentView: UIView?
  var time: Int = 0 {
    didSet {
      timeLabel?.text = stringToGameTime(time)
    }
  }
  var score: Int = 0 {
    didSet {
      scoreLabel?.text = String(score)
    }
  }
  var gameDuration = 60
//  var gameDuration: Int {
//    return GameStatus.status.selectedMode.rawValue * 60
//  }
  var timer: NSTimer?
  
  //Game Client
  var clientView: UIView?
  var beginButton: UIButton?
  var puzzleButton: UIButton?
  var normalButton: UIButton?
  var speedButton: UIButton?
  
  //Game View
  var gameView: GameView?
  var countdownOverlayView: TileView?
  var viewWidth: CGFloat = 0
  var viewHeight: CGFloat = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewWidth = self.view.frame.width
    viewHeight = self.view.frame.height
    configureHUD()
    gameView = GameView(viewWidth: viewWidth, viewHeight: viewHeight, delegate: self)
    self.view.addSubview(gameView!)
    configureStartOptions()
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
    if !GameStatus.status.gameActive {
      gameView?.animateBeginGame()
    }
  }
  
  func startGameplay() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tickTock", userInfo: nil, repeats: true)
      GameStatus.status.gameActive = true
    })
  }
  
  func resetGameState() {
    score = 0
    time = gameDuration
    gameView?.gameOverView?.hidden = true
    gameView?.gameOverView = nil
    gameView?.applyNumberLayoutToTiles(true)
    GameStatus.status.gameActive = false
  }
  
  
  //MARK: HUD
  func configureHUD() {
    configureScoreElements()
    resetGameState()
  }
  
  func configureScoreElements() {
    let offset = (viewWidth - (viewWidth / 1.25)) / 2
    componentView = UIView(frame: CGRectMake(offset, viewHeight / 2.8, viewWidth / 1.25, 30))
    componentView?.backgroundColor = UIColor.clearColor()
    
    let scoreTagLabel = UILabel(frame: CGRectMake(0, -10, 50, 50))
    scoreTagLabel.text = "Score:"
    scoreTagLabel.textColor = UIColor.whiteColor()
    componentView?.addSubview(scoreTagLabel)
    
    scoreLabel = UILabel(frame: CGRectMake(60, -10, 50, 50))
    scoreLabel?.text = "0"
    scoreLabel?.textColor = UIColor.whiteColor()
    componentView?.addSubview(scoreLabel!)
    
    let negativeOffset = viewWidth - (offset + viewWidth / 4.4)
    timeLabel = UILabel(frame: CGRectMake(negativeOffset, -10, 50, 50))
    timeLabel?.text = "0:00"
    timeLabel?.textColor = UIColor.whiteColor()
    componentView?.addSubview(timeLabel!)
    self.view.addSubview(componentView!)
  }
  
  func tickTock() {
    if GameStatus.status.gameActive {
      time--
      if time == 0 {
        gameOver()
      }
    }
  }
  
  func gameOver() {
    timer?.invalidate()
    timer = nil
    GameStatus.status.gameActive = false
    self.gameView?.userInteractionEnabled = false
    self.gameView?.gameOver(score)
//    self.alertShow("Game Over", alertMessage: "Your Score: \(String(score))")
  }

//  func alertShow(alertText :String, alertMessage :String) {
//    let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
//    alert.addAction(UIAlertAction(title: "AGAIN!", style: .Default, handler: { (action) -> Void in
//      self.dismissViewControllerAnimated(true, completion: nil)
//      self.resetGameState()
//      self.beginGame()
//    }))
//    alert.addAction(UIAlertAction(title: "Please, no more", style: .Default, handler: { (action) -> Void in
//      self.dismissViewControllerAnimated(true, completion: nil)
//      self.resetGameState()
//    }))
//    self.presentViewController(alert, animated: true, completion: nil)
//  }
  
  
  //MARK: Game Client
  func configureStartOptions() {
    let offset = (viewWidth - (viewWidth / 1.25)) / 2
    let clientViewWidth = viewWidth / 1.25
    let clientViewHeight = viewWidth / 3.5
    
    clientView = UIView(frame: CGRectMake(offset, viewHeight / 5, clientViewWidth, clientViewHeight))
    clientView?.backgroundColor = UIColor.redColor()
    self.view.addSubview(clientView!)
    
    let buttonX = (clientViewWidth / 2) - 25
    let buttonY = (clientViewHeight / 2) - 25
    beginButton = UIButton(frame: CGRectMake(buttonX, buttonY, 50, 50))
    beginButton?.setTitle("Begin", forState: .Normal)
    beginButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    beginButton?.addTarget(self, action: "beginButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
    clientView?.addSubview(beginButton!)
    configureGameModeUI()
    
  }
  
  func configureGameModeUI() {
    let buttonWidth = (viewWidth / 1.25) / 3
    puzzleButton = UIButton(frame: CGRectMake(0,0,buttonWidth, 20))
    puzzleButton?.setTitle("Puzzle", forState: .Normal)
    puzzleButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    puzzleButton?.backgroundColor = UIColor.lightGrayColor()
    puzzleButton?.addTarget(self, action: "modeButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    normalButton = UIButton(frame: CGRectMake(buttonWidth,0,buttonWidth, 20))
    normalButton?.setTitle("Normal", forState: .Normal)
    normalButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    normalButton?.backgroundColor = UIColor.lightGrayColor()
    normalButton?.addTarget(self, action: "modeButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    speedButton = UIButton(frame: CGRectMake(buttonWidth * 2,0,buttonWidth, 20))
    speedButton?.setTitle("Speed", forState: .Normal)
    speedButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    speedButton?.backgroundColor = UIColor.lightGrayColor()
    speedButton?.addTarget(self, action: "modeButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    switch GameStatus.status.selectedMode {
    case .Puzzle:
      puzzleButton?.backgroundColor = UIColor.darkGrayColor()
    case .Normal:
      normalButton?.backgroundColor = UIColor.darkGrayColor()
    case .Speed:
      speedButton?.backgroundColor = UIColor.darkGrayColor()
    }
    
    clientView?.addSubview(puzzleButton!)
    clientView?.addSubview(normalButton!)
    clientView?.addSubview(speedButton!)
  }
  
  func modeButtonPressed(sender: UIButton) {
    if let puzzleButton = self.puzzleButton, speedButton = self.speedButton, normalButton = self.normalButton {
      switch sender {
      case puzzleButton:
        self.normalButton?.backgroundColor = UIColor.lightGrayColor()
        self.speedButton?.backgroundColor = UIColor.lightGrayColor()
        self.puzzleButton?.backgroundColor = UIColor.darkGrayColor()
        GameStatus.status.selectedMode = .Puzzle
      case normalButton:
        self.normalButton?.backgroundColor = UIColor.darkGrayColor()
        self.speedButton?.backgroundColor = UIColor.lightGrayColor()
        self.puzzleButton?.backgroundColor = UIColor.lightGrayColor()
        GameStatus.status.selectedMode = .Normal
      case speedButton:
        self.normalButton?.backgroundColor = UIColor.lightGrayColor()
        self.speedButton?.backgroundColor = UIColor.darkGrayColor()
        self.puzzleButton?.backgroundColor = UIColor.lightGrayColor()
        GameStatus.status.selectedMode = .Speed
      default:
        break
      }
    }
  }
  
  func toggleClientView() {
    self.clientView?.hidden = true
  }
  
  
  func beginButtonPressed() {
    print("Begin button pressed")
    toggleClientView()
    resetGameState()
    beginGame()
  }
  
}

