//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameViewDelegate, ButtonDelegate {
  
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var pausedView: UIView!
  
  @IBOutlet weak var gameContainerView: UIView!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var highScoreLabel: UILabel!
  @IBOutlet weak var operationIndicatorView: UIView!
  @IBOutlet weak var divideView: OperationImageView!
  @IBOutlet weak var multiplyView: OperationImageView!
  @IBOutlet weak var subtractView: OperationImageView!
  @IBOutlet weak var addView: OperationImageView!
  
  @IBOutlet weak var helperButtonView: ButtonView!
  @IBOutlet weak var helperButtonViewIndicator: UILabel!
  @IBOutlet weak var helperButtonLabel: UILabel!
  
  @IBOutlet weak var helperStreakLabel: UILabel!
  //HUD
  //  var scoreLabel: UILabel?
  
  //  var roundLabel: UILabel?
  var helperPointLabel: UILabel?
  var componentView: UIView?
  var shouldPlayImmediately: Bool = false
  
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
  var helperButtonViewEnabled: Bool = true
  
  //Game Client
  var beginButton: UIButton?
  //  var resetButton: UIButton?
  var helperButton: UIButton?
  
  //Game View
  var gameLaunchView: GameLaunchViewController?
  var gameView: GameViewController?
  var countdownOverlayView: TileView?
  var viewWidth: CGFloat = 0
  var viewHeight: CGFloat = 0
  var operations: Array<Operation>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    timeLabel.adjustsFontSizeToFitWidth = true
    multiplyView.operation = .Multiply
    addView.operation = .Add
    subtractView.operation = .Subtract
    divideView.operation = .Divide
    //   self.navigationController?.navigationBarHidden = true
    setHighScore()
    configureViewStyles()
    setRound(0)
    MultipleHelper.defaultHelper.initializeCombinations()
    viewWidth = self.view.frame.width
    viewHeight = self.view.frame.height
    resetGameState()
//    gameView = GameView(container: gameContainerView, delegate: self)
    configureStartOptions()
  }
  
  override func viewWillDisappear(animated: Bool) {
    //   self.navigationController?.navigationBarHidden = false
    invalidateTimer()
    super.viewWillDisappear(true)
  }
  
  func configureViewStyles() {
    gameContainerView.layer.shadowColor = ThemeHelper.defaultHelper.sw_shadow_color.CGColor
    gameContainerView.layer.shadowOpacity = 0.3
    gameContainerView.layer.shadowOffset = CGSizeZero
    gameContainerView.layer.shadowRadius = 10
    
    let firstColor = ThemeHelper.defaultHelper.sw_background_color
    let secondColor = ThemeHelper.defaultHelper.sw_background_glow_color
    let gradientLayer = CAGradientLayer.verticalGradientLayerForBounds(self.view.bounds, colors: (start: firstColor, end: secondColor), rounded: false)
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
  
  func setGameViewController(controller: GameViewController) {
    self.gameView = controller
  }
  
  func setHelperPoints(points: Int) {
    
    helperButtonViewIndicator.text = "\(points)"
    setStreakLabel()
  }
  
  func setStreakLabel() {
    let streak = ProgressionManager.sharedManager.currentStreak
    let needed = ProgressionManager.sharedManager.currentStreakNeeded
    helperStreakLabel.text = "BONUS STREAK: \(streak)/\(needed)"
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
      //      setHelperButtons()
      gameView?.animateBeginGame()
    }
  }
  
  func setStartTime() {
    time = gameDuration
    setRound(ProgressionManager.sharedManager.currentRound)
  }
  
  func setRound(number: Int) {
    setHelperPoints(ProgressionManager.sharedManager.currentHelperPoints)
//    roundLabel?.text = "LEVEL \(number)"
  }
  
  func startGameplay() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.deactivateHelperPointButton(false, deactivate: false)
      self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.tickTock), userInfo: nil, repeats: true)
      GameStatus.status.gameActive = true
    })
  }
  
  func resetGameState() {
    score = 0
    time = 0
    invalidateTimer()
    gameView?.roundOverView?.removeFromSuperview()
    gameView?.roundOverView = nil
    gameView?.gameOverView?.removeFromSuperview()
    gameView?.gameOverView = nil
    gameView?.applyNumberLayoutToTiles(true)
    GameStatus.status.gameActive = false
    ProgressionManager.sharedManager.reset()
    resetGameUI()
  }
  
  
  //MARK: HUD
  
  func tickTock() {
    if GameStatus.status.gameActive {
      time -= 1
      if time == 0 {
        gameOver()
      }
    }
  }
  
  
  func togglePaused(paused: Bool) {
    if paused {
      self.pausedView.hidden = false
      self.timeLabel.alpha = 0.2
      invalidateTimer()
    } else {
      self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.tickTock), userInfo: nil, repeats: true)
      self.timeLabel.alpha = 1
      self.pausedView.hidden = true
    }
  }
  
  func gameOver(finished: Bool = true) {
    if finished && GameStatus.status.selectedMode == .Ranked {
      reportScore()
    }
    deactivateHelperPointButton(true, deactivate: false)
    invalidateTimer()
    timer = nil
    GameStatus.status.gameActive = false
    gameView?.roundOverView?.removeFromSuperview()
    gameView?.roundOverView = nil
    let highScore = setHighScore()
    self.gameView?.view.userInteractionEnabled = false
    self.gameLaunchView?.gameOver(score, highScore: highScore)
    resetGameState()
    //    self.alertShow("Game Over", alertMessage: "Your Score: \(String(score))")
  }
  
  func setHighScore() -> Bool {
    var newHighScore: Bool = false
    if CurrentUser.info.highScore < score {
      CurrentUser.info.highScore = score
      newHighScore = true
    } else {
      newHighScore = false
    }
    self.highScoreLabel.text = "HIGH SCORE: \(CurrentUser.info.highScore)"
    return newHighScore
  }
  
  func reportScore() {
    print("REPORT SCORE")
//    APIService.sharedService.post(["value": score], url: "score/register") { (res, err) in
//      if let e = err {
//        print("Error reporting score: \(e)")
//      } else {
//        print("Score reported successfully")
//      }
//    }
  }
  
  func configureStartOptions() {
    helperButtonView.becomeButtonForGameView(self, label: helperButtonLabel, delegate: self)
    //TOOD: Set helper button Target to gameView
    helperButtonViewIndicator.text = "\(0)"
    helperButtonViewIndicator.layer.cornerRadius = helperButtonViewIndicator.frame.width / 2
    helperButtonViewIndicator.clipsToBounds = true
    
  }
  
  func buttonPressed(sender: ButtonView) {
    if helperButtonViewEnabled && ProgressionManager.sharedManager.currentHelperPoints > 0 {
      gameView?.helperButtonPressed()
      toggleHelperMode(true)
      // stop the clock, show pause button overlay
    }
  }
  
  //DELEGATE METHOD DON'T DELETE:
  func toggleHelperMode(on: Bool) {
    if on {
      GameStatus.status.gameActive = false
    } else {
      GameStatus.status.gameActive = true
    }
  }
  
  
  func resetGameUI() {
    multiplyView.image = ThemeHelper.defaultHelper.multiplyImageGray
    divideView.image = ThemeHelper.defaultHelper.divideImageGray
    subtractView.image = ThemeHelper.defaultHelper.subtractImageGray
    addView.image = ThemeHelper.defaultHelper.addImageGray
    multiplyView.displayOperationStatus([])
    subtractView.displayOperationStatus([])
    addView.displayOperationStatus([])
    divideView.displayOperationStatus([])
  }
  
  func toggleClientView() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      if let beginButton = self.beginButton, helperButton = self.helperButton {
        if beginButton.hidden {
          helperButton.hidden = true
          beginButton.enabled = true
          beginButton.hidden = false
        } else {
          beginButton.enabled = false
          beginButton.hidden = true
          helperButton.hidden = false
        }
      }
    })
  }
  
  func resetClientOperations(currentOperations: Array<Operation>?) {
    
    func resetImages() {
      let active = ProgressionManager.sharedManager.activeOperations
      self.multiplyView?.image = active.contains(.Multiply) ? ThemeHelper.defaultHelper.multiplyImage : ThemeHelper.defaultHelper.multiplyImageGray
      self.divideView?.image = active.contains(.Divide) ? ThemeHelper.defaultHelper.divideImage : ThemeHelper.defaultHelper.divideImageGray
      self.addView?.image = active.contains(.Add) ? ThemeHelper.defaultHelper.addImage : ThemeHelper.defaultHelper.addImageGray
      self.subtractView?.image = active.contains(.Subtract) ? ThemeHelper.defaultHelper.subtractImage : ThemeHelper.defaultHelper.subtractImageGray
    }
    if let currentOperations = currentOperations {
      resetImages()
      self.operations = currentOperations
      let views: Array<OperationImageView> = [addView, multiplyView, subtractView, divideView]
      views.forEach({$0.displayOperationStatus(currentOperations)})
    } else {
      resetImages()
    }
  }
  
  func deactivateHelperPointButton(remove: Bool, deactivate: Bool) {
      helperButtonView.hidden = remove
      helperButtonViewEnabled = !deactivate
      helperStreakLabel.hidden = remove
  }
  
  func resetButtonPressed() {
    gameOver(false)
    resetGameState()
  }
  
  func beginButtonPressed() {
    beginButton?.enabled = false
    //    resetGameState()
    beginGame()
  }
  
  func invalidateTimer() {
    self.timer?.invalidate()
    self.timer = nil
  }
  
  @IBAction func menuButtonPressed(sender: AnyObject) {
    print("Menu Button Pressed")
    invalidateTimer()
    GameStatus.status.gameActive = false
    ProgressionManager.sharedManager.reset()
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "gameViewEmbed" {
      if let topNav = segue.destinationViewController as? UINavigationController, vc = topNav.topViewController as? GameLaunchViewController {
        vc.delegate = self
        self.gameLaunchView = vc
        vc.containerView = gameContainerView
        if shouldPlayImmediately {
          gameLaunchView?.shouldPlayImmediately = true
          shouldPlayImmediately = false
        }
      }
    }
  }
    
}

