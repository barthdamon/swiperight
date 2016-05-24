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
  var roundLabel: UILabel?
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
  var gameDuration: Int {
    return ProgressionManager.sharedManager.standardRoundDuration
  }
  var timer: NSTimer?
  
  //Game Client
  var clientView: UIView?
  var beginButton: UIButton?
  var resetButton: UIButton?
  var hideButton: UIButton?
  var removeButton: UIButton?
  var revealButton: UIButton?
  
  var multiplyView: UIImageView?
  var divideView: UIImageView?
  var addView: UIImageView?
  var subtractView: UIImageView?
  
  let addImage = UIImage(named: "add")
  let subtractImage = UIImage(named: "subtract")
  let multiplyImage = UIImage(named: "multiply")
  let divideImage = UIImage(named: "divide")
  
  let addImageGray = UIImage(named: "addGray")
  let subtractImageGray = UIImage(named: "subtractGray")
  let multiplyImageGray = UIImage(named: "multiplyGray")
  let divideImageGray = UIImage(named: "divideGray")
  
  let addImageGrayInactive = UIImage(named: "addGrayInactive")
  let subtractImageGrayInactive = UIImage(named: "subtractGrayInactive")
  let multiplyImageGrayInactive = UIImage(named: "multiplyGrayInactive")
  let divideImageGrayInactive = UIImage(named: "divideGrayInactive")
  
  
  //Game View
  var gameView: GameView?
  var countdownOverlayView: TileView?
  var viewWidth: CGFloat = 0
  var viewHeight: CGFloat = 0
  var operations: Array<Operation>?

  override func viewDidLoad() {
    super.viewDidLoad()
    MultipleHelper.defaultHelper.initializeCombinations()
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
      score += 1
    } else {
      score -= 1
    }
  }
  
  func addTime(seconds: Int) {
    time += seconds
    //some fancy animation
  }
  
  func beginGame() {
    if !GameStatus.status.gameActive {
      setRound(0)
      gameView?.animateBeginGame()
    }
  }
  
  func setRound(number: Int) {
    if number >= 23 {
      roundLabel?.text = "MAX"
    } else {
      roundLabel?.text = "Round: \(number)"
    }
  }
  
  func startGameplay() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.tickTock), userInfo: nil, repeats: true)
      GameStatus.status.gameActive = true
    })
  }
  
  func resetGameState() {
    score = 0
    time = gameDuration
    gameView?.intermissionTimer.invalidate()
    gameView?.roundOverView?.removeFromSuperview()
    gameView?.roundOverView = nil
    gameView?.gameOverView?.removeFromSuperview()
    gameView?.gameOverView = nil
    gameView?.applyNumberLayoutToTiles(true)
    resetClientOperations(nil)
    GameStatus.status.gameActive = false
  }
  
  func resetTime() {
    time = gameDuration
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
    
    roundLabel = UILabel(frame: CGRectMake(negativeOffset - 100, -10, 100, 50))
    roundLabel?.text = "Round: 0"
    roundLabel?.textColor = UIColor.whiteColor()
    componentView?.addSubview(roundLabel!)
    
    timeLabel = UILabel(frame: CGRectMake(negativeOffset, -10, 50, 50))
    timeLabel?.text = "0:00"
    timeLabel?.textColor = UIColor.whiteColor()
    componentView?.addSubview(timeLabel!)
    self.view.addSubview(componentView!)
  }
  
  func tickTock() {
    if GameStatus.status.gameActive {
      time -= 1
      if time == 0 {
        gameOver()
      }
    }
  }
  
  func gameOver() {
    timer?.invalidate()
    timer = nil
    GameStatus.status.gameActive = false
    gameView?.roundOverView?.removeFromSuperview()
    gameView?.roundOverView = nil
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
//    clientView?.backgroundColor = UIColor.redColor()
    self.view.addSubview(clientView!)
    
    let buttonX = (clientViewWidth / 2) - 50
    let buttonY = (clientViewHeight / 2) - 40
    beginButton = UIButton(frame: CGRectMake(buttonX, buttonY, 100, 70))
    beginButton?.setTitle("Begin", forState: .Normal)
    beginButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    beginButton?.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
    beginButton?.setTitleColor(UIColor.darkGrayColor(), forState: .Highlighted)
    beginButton?.titleLabel?.font = UIFont.systemFontOfSize(30)
    beginButton?.addTarget(self, action: #selector(ViewController.beginButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
    
    resetButton = UIButton(frame: CGRectMake(buttonX, buttonY, 100, 70))
    resetButton?.setTitle("Reset", forState: .Normal)
    resetButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    resetButton?.setTitleColor(UIColor.darkGrayColor(), forState: .Highlighted)
    resetButton?.titleLabel?.font = UIFont.systemFontOfSize(30)
    resetButton?.addTarget(self, action: #selector(ViewController.resetButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
    resetButton?.hidden = true
    
    clientView?.addSubview(beginButton!)
    clientView?.addSubview(resetButton!)
    configureHelperOptionUI()
    configureOperationFeedback()
    
  }
  
  func configureOperationFeedback() {
    if let clientView = clientView {
      let width = clientView.frame.width / 2
      let height = clientView.frame.height
      let offset = width / 2
      
      let buttonsView = UIView(frame: CGRectMake(offset,height - 30,width,30))
      
      let operationWidth = buttonsView.frame.width / 4
      addView = UIImageView(frame: CGRectMake(0,0,operationWidth, 30))
      addView?.image = addImageGrayInactive
      addView?.contentMode = .ScaleAspectFill
      subtractView = UIImageView(frame: CGRectMake(operationWidth,0,operationWidth, 30))
      subtractView?.image = subtractImageGrayInactive
      subtractView?.contentMode = .ScaleAspectFill
      multiplyView = UIImageView(frame: CGRectMake(operationWidth * 2,0,operationWidth, 30))
      multiplyView?.contentMode = .ScaleAspectFill
      multiplyView?.image = multiplyImageGrayInactive
      divideView = UIImageView(frame: CGRectMake(operationWidth * 3,0,operationWidth, 30))
      divideView?.image = divideImageGrayInactive
      divideView?.contentMode = .ScaleAspectFill
      
      buttonsView.addSubview(addView!)
      buttonsView.addSubview(subtractView!)
      buttonsView.addSubview(multiplyView!)
      buttonsView.addSubview(divideView!)
      
      clientView.addSubview(buttonsView)
    }
  }
  
  func setHelperButtons() {
    let points = ProgressionManager.sharedManager.currentHelperPoints
    let showRemove = points >= 2
    let showHide = points >= 1
    let showReveal = points >= 3
    if showRemove {
      if ProgressionManager.sharedManager.multipleOperationsDisplayActive {
        
      } else {
        
      }
    }

  }
  
  func configureHelperOptionUI() {
    let buttonWidth = (viewWidth / 1.25) / 3
    hideButton = UIButton(frame: CGRectMake(0,0,buttonWidth, 20))
    hideButton?.setTitle("Hide", forState: .Normal)
    hideButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    hideButton?.backgroundColor = UIColor.lightGrayColor()
    hideButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    removeButton = UIButton(frame: CGRectMake(buttonWidth,0,buttonWidth, 20))
    removeButton?.setTitle("Remove", forState: .Normal)
    removeButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    removeButton?.backgroundColor = UIColor.lightGrayColor()
    removeButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    revealButton = UIButton(frame: CGRectMake(buttonWidth * 2,0,buttonWidth, 20))
    revealButton?.setTitle("Reveal", forState: .Normal)
    revealButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    revealButton?.backgroundColor = UIColor.lightGrayColor()
    revealButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    
    
//    switch GameStatus.status.selectedMode {
//    case .Puzzle:
//      puzzleButton?.backgroundColor = UIColor.darkGrayColor()
//    case .Normal:
//      normalButton?.backgroundColor = UIColor.darkGrayColor()
//    case .Speed:
//      speedButton?.backgroundColor = UIColor.darkGrayColor()
//    }
    
    clientView?.addSubview(hideButton!)
    clientView?.addSubview(removeButton!)
    clientView?.addSubview(revealButton!)
  }
  
  
  func helperButtonPressed(sender: UIButton) {
    if let hideButton = self.hideButton, revealButton = self.revealButton, removeButton = self.removeButton {
      switch sender {
      case hideButton:
        gameView?.helperSelected(.Hide)
      case revealButton:
        gameView?.helperSelected(.Reveal)
      case removeButton:
        
        gameView?.helperSelected(.Remove)
      default:
        break
      }
    }
    time = gameDuration
  }
  
  func toggleClientView() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      if let beginButton = self.beginButton, resetButton = self.resetButton {
        if beginButton.hidden {
          resetButton.hidden = true
          beginButton.enabled = true
          beginButton.hidden = false
        } else {
          beginButton.enabled = false
          beginButton.hidden = true
          resetButton.hidden = false
        }
      }
    })
  }
  
  func resetClientOperations(currentOperations: Array<Operation>?) {
    
    func resetImages() {
      let active = ProgressionManager.sharedManager.activeOperations
      self.multiplyView?.image = active.contains(.Multiply) ? multiplyImageGray : multiplyImageGrayInactive
      self.divideView?.image = active.contains(.Divide) ? divideImageGray : divideImageGrayInactive
      self.addView?.image = active.contains(.Add) ? addImageGray : addImageGrayInactive
      self.subtractView?.image = active.contains(.Subtract) ? subtractImageGray : subtractImageGrayInactive
    }
    if let currentOperations = currentOperations {
      resetImages()
      self.operations = currentOperations
      for operation in currentOperations {
        switch operation {
        case .Add:
          self.addView?.image = addImage
        case .Subtract:
          self.subtractView?.image = subtractImage
        case .Multiply:
          self.multiplyView?.image = multiplyImage
        case .Divide:
          self.divideView?.image = divideImage
        }
      }
    } else {
      resetImages()
    }
  }
  
  func resetButtonPressed() {
    gameOver()
    resetGameState()
  }
  
  func beginButtonPressed() {
    beginButton?.enabled = false
    resetGameState()
    beginGame()
  }
  
}

