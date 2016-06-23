//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameViewDelegate, ButtonDelegate {
  
  
  @IBOutlet weak var bonusStreakLabel: UILabel!
  
  @IBOutlet weak var adView: UIView!
  @IBOutlet weak var tutorialLabel: UILabel!
  
  @IBOutlet weak var timeLabel: UILabel!
//  @IBOutlet weak var pausedLabel: UILabel!
  
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
  
//  var time: Int = 0 {
//    didSet {
//      timeLabel?.text = stringToGameTime(time)
//    }
//  }
//  var score: Int = 0 {
//    didSet {
//      scoreLabel?.text = "SCORE: \(score)"
//    }
//  }
//  var gameDuration: Int {
//    return ProgressionManager.sharedManager.standardRoundDuration
//  }
//  var timer: NSTimer?
  var helperButtonViewEnabled: Bool = true
  
  //Game Client
  var beginButton: UIButton?
  //  var resetButton: UIButton?
  var helperButton: UIButton?
  
  //Game View
  var gameViewNav: UINavigationController?
  var gameLaunchView: GameLaunchViewController?
  var gameView: GameViewController?
  var countdownOverlayView: TileView?
  var viewWidth: CGFloat = 0
  var viewHeight: CGFloat = 0
  var operations: Array<Operation>?
  
  var startOptionsConfigured: Bool = false
  
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
    viewWidth = self.view.frame.width
    viewHeight = self.view.frame.height
    resetGameState()
//    gameView = GameView(container: gameContainerView, delegate: self)
    adView?.userInteractionEnabled = false
  }
  
  
  override func viewWillDisappear(animated: Bool) {
    //   self.navigationController?.navigationBarHidden = false
    invalidateTimer()
    GameStatus.status.inMenu = true
    super.viewWillDisappear(true)
  }
  
  override func viewDidAppear(animated: Bool) {
    GameStatus.status.inMenu = false
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !startOptionsConfigured {
      configureStartOptions()
      startOptionsConfigured = true
    }

    if UIScreen.mainScreen().bounds.height < 1000 {
      self.tutorialLabel.font = ThemeHelper.defaultHelper.sw_mini_tutorial_font
    }
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
      GameStatus.status.score += 1
    } else {
      GameStatus.status.score -= 1
    }
    self.scoreLabel.text = "SCORE: \(GameStatus.status.score)"
  }
  
  func setGameViewController(controller: GameViewController) {
    self.gameView = controller
  }
  
  func setHelperPoints(points: Int, callback: (Bool) -> ()) {
//    self.helperButtonViewIndicator.text = "\(points)"
    setStreakLabel()
    UIView.animateWithDuration(0.3, animations: {
      if let text = self.helperButtonViewIndicator.text, current = Int(text) where current >= points {
      } else {
        self.helperButtonViewIndicator.transform = CGAffineTransformMakeScale(1.3,1.3)
      }
    }) { (done) in
      self.helperButtonViewIndicator.text = "\(points)"
      UIView.animateWithDuration(0.3, animations: {
        self.helperButtonViewIndicator.transform = CGAffineTransformIdentity
        self.bonusStreakLabel.transform = CGAffineTransformIdentity
        }, completion: { (done) in
        callback(true)
      })
    }
  }
  
  func setStreakLabel() {
    self.bonusStreakLabel.text = "ABILITY STREAK: \(ProgressionManager.sharedManager.currentStreak)/3"
  }
  

  
  func addTime(seconds: Int) {
    GameStatus.status.time += seconds
    timeLabel?.text = stringToGameTime(GameStatus.status.time)
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
    GameStatus.status.time = GameStatus.status.gameDuration
    timeLabel?.text = stringToGameTime(GameStatus.status.time)
    setRound(ProgressionManager.sharedManager.currentRound)
  }
  
  func setRound(number: Int) {
    setHelperPoints(ProgressionManager.sharedManager.currentHelperPoints, callback: { (done) in
    })
//    roundLabel?.text = "LEVEL \(number)"
  }
  
  func startGameplay() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.toggleAdViewVisible(false)
      self.deactivateHelperPointButton(false, deactivate: false)
      if GameStatus.status.timer == nil {
        GameStatus.status.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.tickTock), userInfo: nil, repeats: true)
      }
      GameStatus.status.gameActive = true
    })
  }
  
  func resetGameState() {
    GameStatus.status.score = 0
    GameStatus.status.time = 0
    scoreLabel.text = "SCORE: \(GameStatus.status.score)"
    timeLabel?.text = stringToGameTime(GameStatus.status.time)
    invalidateTimer()
    gameView?.applyNumberLayoutToTiles(true)
    GameStatus.status.gameActive = false
    ProgressionManager.sharedManager.reset()
    resetGameUI()
  }
  
  
  //MARK: HUD
  
  func tickTock() {
    if !GameStatus.status.inMenu {
      if GameStatus.status.gameActive && GameStatus.status.timer != nil {
        GameStatus.status.time -= 1
        if GameStatus.status.time == 0 {
          gameOver()
        }
        timeLabel?.text = stringToGameTime(GameStatus.status.time)
      }
    } else {
      print("Timer invalidated from tick tock")
      self.invalidateTimer()
    }
  }
  
  
  func togglePaused(paused: Bool) {
    GameStatus.status.gameActive = !paused
    if paused {
//      self.pausedLabel.hidden = false
      self.timeLabel.alpha = 0.2
      invalidateTimer()
    } else {
      if GameStatus.status.gameMode == .Standard {
        GameStatus.status.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.tickTock), userInfo: nil, repeats: true)
      } else {
        invalidateTimer()
      }
      self.timeLabel.alpha = 1
//      self.pausedLabel.hidden = true
    }
  }
  
  func gameOver(finished: Bool = true) {
    if finished && GameStatus.status.gameMode == .Standard {
      reportScore()
    }
    deactivateHelperPointButton(true, deactivate: false)
    invalidateTimer()
    GameStatus.status.timer = nil
    GameStatus.status.gameActive = false
    let highScore = setHighScore()
    self.gameView?.view.userInteractionEnabled = false
    self.gameLaunchView?.gameOver(GameStatus.status.score, highScore: highScore)
    if GameStatus.status.gameMode == .Standard {
      resetGameState()
    }
    toggleAdViewVisible(true)
    self.adView.hidden = false
    //    self.alertShow("Game Over", alertMessage: "Your Score: \(String(score))")
  }
  
  func setHighScore() -> Bool {
    var newHighScore: Bool = false
    if CurrentUser.info.highScore < GameStatus.status.score {
      CurrentUser.info.highScore = GameStatus.status.score
      newHighScore = true
    } else {
      newHighScore = false
    }
    self.highScoreLabel.text = "BEST: \(CurrentUser.info.highScore)"
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
    print("Helper Button Pressed")
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
    adView.hidden = true
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
  }
  
  func beginButtonPressed() {
    beginButton?.enabled = false
    //    resetGameState()
    beginGame()
  }
  
  func invalidateTimer() {
    GameStatus.status.timer?.invalidate()
    GameStatus.status.timer = nil
    self.tutorialBlinkingTimer?.invalidate()
    self.tutorialBlinkingTimer = nil
    self.gameView?.highlightTileTimer?.invalidate()
    self.gameView?.highlightTileTimer = nil
//    self.gameView?.helperPointController?.hideButtonFlashTimer?.invalidate()
//    self.gameView?.helperPointController?.hideButtonFlashTimer = nil
  }
  
  func timerAlreadyTocking() -> Bool {
    if let _ = GameStatus.status.timer {
      return true
    } else {
      return false
    }
  }
  
  @IBAction func menuButtonPressed(sender: AnyObject) {
    print("Menu Button Pressed")
    invalidateTimer()
    GameStatus.status.inMenu = true
    GameStatus.status.gameActive = false
    ProgressionManager.sharedManager.reset()
    GameStatus.status.tutorialStage = 0
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "gameViewEmbed" {
      if let topNav = segue.destinationViewController as? UINavigationController, vc = topNav.topViewController as? GameLaunchViewController {
        self.gameViewNav = topNav
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
  var tutorialBlinkingTimer: NSTimer?
  let tutorialTimerTime: Double = 1.5
  let tutorialBlinkTime: Double = 0.75
  
  var blinkingOperations: Bool = false
  var blinkingTimer: Bool = false
  var blinkingHelperPoints: Bool = false
  var blinkingHelperPointStreaks: Bool = false
  
  func blinkOperations() {
    if blinkingOperations {
      self.addView.image = ThemeHelper.defaultHelper.addImage
      self.subtractView.image = ThemeHelper.defaultHelper.subtractImage
      self.multiplyView.image = ThemeHelper.defaultHelper.multiplyImage
      self.divideView.image = ThemeHelper.defaultHelper.divideImage
      UIView.animateWithDuration(tutorialBlinkTime, animations: {
        self.addView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.subtractView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.multiplyView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.divideView.transform = CGAffineTransformMakeScale(1.3, 1.3)
      }) { (done) in
        if self.blinkingHelperPoints {
          UIView.animateWithDuration(self.tutorialBlinkTime, animations: {
            self.addView.transform = CGAffineTransformIdentity
            self.subtractView.transform = CGAffineTransformIdentity
            self.multiplyView.transform = CGAffineTransformIdentity
            self.divideView.transform = CGAffineTransformIdentity
          })
        }
      }
    }
  }
  
  func blinkTimer() {
    if blinkingTimer {
      UIView.animateWithDuration(tutorialBlinkTime, animations: {
        self.timeLabel.transform = CGAffineTransformMakeScale(1.3, 1.3)
      }) { (done) in
        UIView.animateWithDuration(self.tutorialBlinkTime, animations: {
          self.timeLabel.transform = CGAffineTransformIdentity
        })
      }
    }
  }
  
  func blinkHelperPoints() {
    if blinkingHelperPoints {
      UIView.animateWithDuration(tutorialBlinkTime, animations: {
        if self.blinkingHelperPointStreaks {
          self.bonusStreakLabel.transform = CGAffineTransformMakeScale(1.08, 1.08)
        }
        self.helperButtonLabel.transform = CGAffineTransformMakeScale(1.08, 1.08)
      }) { (done) in
        UIView.animateWithDuration(self.tutorialBlinkTime, animations: {
          self.bonusStreakLabel.transform = CGAffineTransformIdentity
          self.helperButtonView.transform = CGAffineTransformIdentity
          self.helperButtonLabel.transform = CGAffineTransformIdentity
        })
      }
    }
  }
  
  func setBlinkingTimerOn(on: Bool) {
    blinkingTimer = on
    self.tutorialBlinkingTimer?.invalidate()
    self.tutorialBlinkingTimer = nil
    if on {
      blinkTimer()
      if tutorialBlinkingTimer == nil {
        self.tutorialBlinkingTimer = NSTimer.scheduledTimerWithTimeInterval(tutorialTimerTime, target: self, selector: #selector(ViewController.blinkTimer), userInfo: nil, repeats: true)
      }
    }
  }
  
  func setBlinkingOperationsOn(on: Bool) {
    blinkingOperations = on
    self.tutorialBlinkingTimer?.invalidate()
    self.tutorialBlinkingTimer = nil
    if on {
      blinkOperations()
      self.tutorialBlinkingTimer = NSTimer.scheduledTimerWithTimeInterval(tutorialTimerTime, target: self, selector: #selector(ViewController.blinkOperations), userInfo: nil, repeats: true)
    }
  }
  
  func setBlinkingHelperPointsOn(on: Bool, withStreaks: Bool, hideStreaks: Bool) {
    self.tutorialBlinkingTimer?.invalidate()
    self.tutorialBlinkingTimer = nil
    blinkingHelperPoints = on
    blinkingHelperPointStreaks = withStreaks
    self.helperButtonView.hidden = !on
    if on {
      blinkHelperPoints()
      self.tutorialBlinkingTimer = NSTimer.scheduledTimerWithTimeInterval(tutorialTimerTime, target: self, selector: #selector(ViewController.blinkHelperPoints), userInfo: nil, repeats: true)
    }
  }
  
  func setTutorialLabelText(text: String?) {
    if let text = text {
      self.helperButtonView.hidden = true
      tutorialLabel.hidden = false
      tutorialLabel.text = text
    } else {
      tutorialLabel.hidden = true
    }
  }
  
  func launchForEndTutorial(text: String) {
    ProgressionManager.sharedManager.reset()
    GameStatus.status.gameMode = .Standard
    GameStatus.status.tutorialStage = 0
    gameViewNav?.popToRootViewControllerAnimated(true)
    gameLaunchView?.tutorialText = text
    gameLaunchView?.startGameView()
  }
  
  func hideBonusButtonView(hide: Bool) {
    self.helperButtonView.hidden = hide
  }
  
  func toggleAdViewVisible(visible: Bool) {
    self.adView.hidden = !visible
  }
  
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

