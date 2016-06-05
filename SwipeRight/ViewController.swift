//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameViewDelegate {

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var gameViewContainer: UIView!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var roundLabel: UILabel!
  @IBOutlet weak var highScoreLabel: UILabel!
  @IBOutlet weak var operationIndicatorView: UIView!
  @IBOutlet weak var divideView: UIImageView!
  @IBOutlet weak var multiplyView: UIImageView!
  @IBOutlet weak var subtractView: UIImageView!
  @IBOutlet weak var addView: UIImageView!
  
  
  //HUD
//  var scoreLabel: UILabel?

//  var roundLabel: UILabel?
  var helperPointLabel: UILabel?
  var componentView: UIView?
  var time: Int = 0 {
    didSet {
      timeLabel?.text = stringToGameTime(time)
    }
  }
  var score: Int = 0 {
    didSet {
      scoreLabel?.text = "\(score)"
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
 //   self.navigationController?.navigationBarHidden = true
    configureViewStyles()

    MultipleHelper.defaultHelper.initializeCombinations()
    viewWidth = self.view.frame.width
    viewHeight = self.view.frame.height
    configureHUD()
    gameView = GameView(container: gameViewContainer, delegate: self)
    configureStartOptions()
  }
  
  override func viewWillDisappear(animated: Bool) {
 //   self.navigationController?.navigationBarHidden = false
  }
  
  func configureViewStyles() {
    gameViewContainer.layer.shadowColor = ThemeHelper.defaultHelper.sw_gameview_shadow_color.CGColor
    gameViewContainer.layer.shadowOpacity = 1
    gameViewContainer.layer.shadowOffset = CGSizeZero
    gameViewContainer.layer.shadowRadius = 2
    
    let firstColor = ThemeHelper.defaultHelper.sw_blue_color
    let secondColor = ThemeHelper.defaultHelper.sw_green_color
    let gradientLayer = CAGradientLayer.verticalGradientLayerForBounds(self.view.bounds, colors: (start: firstColor, end: secondColor))
    self.view.layer.hidden = false
    self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
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
  
  func getWidth() -> CGFloat {
    return self.view.frame.width
  }
  
  func beginGame() {
    if !GameStatus.status.gameActive {
      setRound(0)
      setHelperButtons()
      gameView?.animateBeginGame()
    }
  }
  
  func setRound(number: Int) {
//    if number >= 15 {
//      roundLabel?.text = "MAX"
//    } else {
      roundLabel?.text = "LEVEL \(number)"
//    }
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
    GameStatus.status.gameActive = false
    ProgressionManager.sharedManager.reset()
    resetGameUI()
  }
  
  func resetTime() {
    time = gameDuration
  }
  
  
  //MARK: HUD
  func configureHUD() {
    resetGameState()
  }
  
  func tickTock() {
    if GameStatus.status.gameActive {
      time -= 1
      if time == 0 {
        gameOver()
      }
    }
  }
  
  func gameOver(finished: Bool = true) {
    if finished && GameStatus.status.selectedMode == .Ranked {
      reportScore()
    }
    timer?.invalidate()
    timer = nil
    GameStatus.status.gameActive = false
    gameView?.roundOverView?.removeFromSuperview()
    gameView?.roundOverView = nil
    self.gameView?.userInteractionEnabled = false
    self.gameView?.gameOver(score)
    resetGameState()
//    self.alertShow("Game Over", alertMessage: "Your Score: \(String(score))")
  }
  
  func reportScore() {
    APIService.sharedService.post(["value": score], url: "score/register") { (res, err) in
      if let e = err {
        print("Error reporting score: \(e)")
      } else {
        print("score reported successfully")
      }
    }
  }
  
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
//    configureHelperOptionUI()
    
  }
  
  func setHelperButtons() {
    let points = ProgressionManager.sharedManager.currentHelperPoints
    guard let layout = gameView?.currentLayout, combo = layout.winningCombination else { return }
    self.helperPointLabel?.text = "Helpers: \(points)"
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
  
  func resetGameUI() {
    revealButton?.backgroundColor = .darkGrayColor()
    hideButton?.backgroundColor = .darkGrayColor()
    removeButton?.backgroundColor = .darkGrayColor()
    multiplyView?.image = multiplyImageGrayInactive
    divideView?.image = divideImageGrayInactive
    subtractView?.image = subtractImageGrayInactive
    addView?.image = addImageGrayInactive
  }
  
  func configureHelperOptionUI() {
    let buttonWidth = (viewWidth / 1.25) / 3
    hideButton = UIButton(frame: CGRectMake(0,0,buttonWidth, 20))
    hideButton?.setTitle("Hide", forState: .Normal)
    hideButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    hideButton?.backgroundColor = UIColor.darkGrayColor()
    hideButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    hideButton?.enabled = false
    
    removeButton = UIButton(frame: CGRectMake(buttonWidth,0,buttonWidth, 20))
    removeButton?.setTitle("Remove", forState: .Normal)
    removeButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    removeButton?.backgroundColor = UIColor.darkGrayColor()
    removeButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    removeButton?.enabled = false
    
    revealButton = UIButton(frame: CGRectMake(buttonWidth * 2,0,buttonWidth, 20))
    revealButton?.setTitle("Reveal", forState: .Normal)
    revealButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    revealButton?.backgroundColor = UIColor.darkGrayColor()
    revealButton?.addTarget(self, action: #selector(ViewController.helperButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    revealButton?.enabled = false
    
    clientView?.addSubview(hideButton!)
    clientView?.addSubview(removeButton!)
    clientView?.addSubview(revealButton!)
  }
  
  
  func helperButtonPressed(sender: UIButton) {
    guard let layout = gameView?.currentLayout, combo = layout.winningCombination else { return }
    if let hideButton = self.hideButton, revealButton = self.revealButton, removeButton = self.removeButton {
      switch sender {
      case hideButton:
        gameView?.helperSelected(.Hide)
        // hide a tile that is extra
      case revealButton:
        gameView?.helperSelected(.Reveal)
        // light up a tile selected
      case removeButton:
        let filteredOperations = ProgressionManager.sharedManager.activeOperations.filter({$0 == combo.operation})
        resetClientOperations(filteredOperations)
        gameView?.helperSelected(.Remove)
      default:
        break
      }
    }
    time = gameDuration
    setHelperButtons()
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
    gameOver(false)
    resetGameState()
  }
  
  func beginButtonPressed() {
    beginButton?.enabled = false
    resetGameState()
    beginGame()
  }
  
  @IBAction func menuButtonPressed(sender: AnyObject) {
    print("Menu Button Pressed")
  }
}

