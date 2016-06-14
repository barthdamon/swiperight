//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameViewDelegate, ButtonDelegate {
  
  @IBOutlet weak var addStreakLabel: UILabel!
  @IBOutlet weak var subtractStreakLabel: UILabel!
  @IBOutlet weak var multiplyStreakLabel: UILabel!
  @IBOutlet weak var divideStreakLabel: UILabel!
  
  @IBOutlet weak var bonusStreakLabel: UILabel!
  @IBOutlet weak var bonusStreakView: UIView!
  @IBOutlet weak var adView: UIView!
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
    let gradientLayer = CAGradientLayer.verticalGradientLayerForBounds(self.view.bounds, colors: (start: firstColor, end: secondColor), rounded: 0)
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
  
  func setHelperPoints(points: Int, callback: (Bool) -> ()) {
    self.setStreakLabels({ (done) in
      UIView.animateWithDuration(0.3, animations: {
        if let text = self.helperButtonViewIndicator.text, current = Int(text) where current >= points {
        } else {
          self.helperButtonViewIndicator.transform = CGAffineTransformMakeScale(1.3,1.3)
        }
      }) { (done) in
        self.helperButtonViewIndicator.text = "\(points)"
        UIView.animateWithDuration(0.3, animations: {
          self.helperButtonViewIndicator.transform = CGAffineTransformIdentity
          self.addStreakLabel.transform = CGAffineTransformIdentity
          self.subtractStreakLabel.transform = CGAffineTransformIdentity
          self.multiplyStreakLabel.transform = CGAffineTransformIdentity
          self.divideStreakLabel.transform = CGAffineTransformIdentity
          }, completion: { (done) in
          callback(true)
        })
      }
    })
  }
  
  func setStreakLabels(callback: (Bool) -> ()) {
    
    func placeText(needed: Int) {
      addStreakLabel.text = "\(ProgressionManager.sharedManager.currentAddStreak)/\(needed)"
      subtractStreakLabel.text = "\(ProgressionManager.sharedManager.currentSubtractStreak)/\(needed)"
      multiplyStreakLabel.text = "\(ProgressionManager.sharedManager.currentMultiplyStreak)/\(needed)"
      divideStreakLabel.text = "\(ProgressionManager.sharedManager.currentDivideStreak)/\(needed)"
    }
    
    let active = ProgressionManager.sharedManager.activeOperations
    let needed = ProgressionManager.sharedManager.currentStreakNeeded
    // hide the label if it isn't in the active operations
    // animate it growing if it reaches its max
    if active.contains(.Add) {
      addStreakLabel.hidden = false
    } else {
      addStreakLabel.hidden = true
    }
    if active.contains(.Subtract) {
      subtractStreakLabel.hidden = false
    } else {
      subtractStreakLabel.hidden = true
    }
    if active.contains(.Multiply) {
      multiplyStreakLabel.hidden = false
    } else {
      multiplyStreakLabel.hidden = true
    }
    if active.contains(.Divide) {
      divideStreakLabel.hidden = false
    } else {
      divideStreakLabel.hidden = true
    }
    
    let manager = ProgressionManager.sharedManager
    var labelToAnimate: UILabel?
    if manager.streakReached(.Add) {
      labelToAnimate = addStreakLabel
    } else if manager.streakReached(.Subtract) {
      labelToAnimate = subtractStreakLabel
    } else if manager.streakReached(.Multiply) {
      labelToAnimate = multiplyStreakLabel
    } else if manager.streakReached(.Divide) {
      labelToAnimate = divideStreakLabel
    }
    if let label = labelToAnimate {
      UIView.animateWithDuration(0.3, animations: { 
        label.transform = CGAffineTransformMakeScale(1.6, 1.6)
        }, completion: { (done) in
          placeText(needed)
          callback(true)
      })
    } else {
      placeText(needed)
      callback(true)
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
      //      setHelperButtons()
      gameView?.animateBeginGame()
    }
  }
  
  func setStartTime() {
    time = gameDuration
    setRound(ProgressionManager.sharedManager.currentRound)
  }
  
  func setRound(number: Int) {
    setHelperPoints(ProgressionManager.sharedManager.currentHelperPoints, callback: { (done) in
    })
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
    GameStatus.status.gameActive = !paused
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
    if finished && GameStatus.status.gameMode == .Standard {
      reportScore()
    }
    deactivateHelperPointButton(true, deactivate: false)
    invalidateTimer()
    timer = nil
    GameStatus.status.gameActive = false
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
    helperButtonViewIndicator.layer.cornerRadius = helperButtonViewIndicator.bounds.height / 2
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
    bonusStreakLabel.hidden = remove
    bonusStreakView.hidden = remove
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
  
  
  
  
  //MARK: Tutorial Mode
  
  @IBAction func importantButtonPressed(sender: UIButton) {
    let tableViewController = UITableViewController()
    tableViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
    tableViewController.preferredContentSize = CGSizeMake(400, 400)
    
    presentViewController(tableViewController, animated: true, completion: nil)
    
    let popoverPresentationController = tableViewController.popoverPresentationController
    popoverPresentationController?.sourceView = sender
    popoverPresentationController?.sourceRect = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height)
  }
  
}

