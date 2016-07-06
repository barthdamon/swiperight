//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit
import GameKit
import GoogleMobileAds

class ViewController: UIViewController, GameViewDelegate, ButtonDelegate, GKGameCenterControllerDelegate {
  
  
  @IBOutlet weak var muteButton: UIButton!
  @IBOutlet weak var bonusStreakLabel: UILabel!
  
  @IBOutlet weak var adView: DFPBannerView!
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
  
  @IBOutlet weak var revealTileLabel: UILabel!
  @IBOutlet weak var revealTileIndicator: UILabel!
  @IBOutlet weak var hideTileButtonView: ButtonView!
  @IBOutlet weak var revealTileButtonView: ButtonView!
  @IBOutlet weak var helperButtonView: UIView!
  @IBOutlet weak var hideTileIndicator: UILabel!
  @IBOutlet weak var helperButtonViewIndicator: UILabel!
  @IBOutlet weak var helperButtonLabel: UILabel!
  //HUD
  //  var scoreLabel: UILabel?
  
  //  var roundLabel: UILabel?
  var helperPointLabel: UILabel?
  var componentView: UIView?
  var shouldPlayImmediately: Bool = false
  
  //todo: get from user pref
  
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
    if SoundManager.defaultManager.muted {
      self.muteButton.setImage(ThemeHelper.defaultHelper.soundOffImage, forState: .Normal)
    }
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
    SoundManager.defaultManager.shutDownSoundSystem()
    super.viewWillDisappear(true)
  }
  
  override func viewDidAppear(animated: Bool) {
    GameStatus.status.inMenu = false
    startOptionsConfigured = true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !startOptionsConfigured {
      configureStartOptions()
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
    var more = false
    if let text = self.helperButtonViewIndicator.text, current = Int(text) where current < points {
      more = true
    }
    setStreakLabel()
    UIView.animateWithDuration(0.3, animations: {
      if more {
        self.helperButtonViewIndicator.transform = CGAffineTransformMakeScale(1.3,1.3)
      }
    }) { (done) in
      self.helperButtonViewIndicator.text = "\(points)"
      if GameStatus.status.gameActive && more && points != 0 {
        SoundManager.defaultManager.playSound(.AbilityPoint)
      }
      UIView.animateWithDuration(0.3, animations: {
        self.helperButtonViewIndicator.transform = CGAffineTransformIdentity
        self.bonusStreakLabel.transform = CGAffineTransformIdentity
        }, completion: { (done) in
        self.activateHelperButtons()
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
      if GameStatus.status.gameMode == .Standard {
        self.toggleAdViewVisible(true)
      }
      self.deactivateHelperPointButton(false, deactivate: false)
      if GameStatus.status.timer == nil {
        GameStatus.status.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.tickTock(_:)), userInfo: nil, repeats: true)
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
  
  func tickTock(sender: NSTimer) {
    if sender != GameStatus.status.timer {
      sender.invalidate()
      print("Resilient timers not dying...")
    } else {
      if !GameStatus.status.inMenu {
        if GameStatus.status.gameActive && GameStatus.status.timer != nil {
          GameStatus.status.time -= 1
          if GameStatus.status.time == 0 {
            gameOver()
          }
          timeLabel?.text = stringToGameTime(GameStatus.status.time)
        }
      } else {
        sender.invalidate()
        print("Timer invalidated from tick tock")
        self.invalidateTimer()
      }
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
      reportScore({ (done) in
      })
    }
    SoundManager.defaultManager.playSound(.GameOver)
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
//    toggleAdViewVisible(true)
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
  
  func configureStartOptions() {
    hideTileButtonView.becomeButtonForGameView(self, label: helperButtonLabel, delegate: self)
    revealTileButtonView.becomeButtonForGameView(self, label: revealTileLabel, delegate: self)
    //TOOD: Set helper button Target to gameView
    helperButtonViewIndicator.text = "\(0)"
    helperButtonViewIndicator.layer.cornerRadius = helperButtonViewIndicator.bounds.height / 2
    helperButtonViewIndicator.clipsToBounds = true
    
  }
  
  
  //DELEGATE METHOD DON'T DELETE:
  func toggleHelperMode(on: Bool) {
    if on {
      helperButtonViewEnabled = false
      GameStatus.status.gameActive = false
    } else {
      GameStatus.status.gameActive = true
      helperButtonViewEnabled = true
    }
    self.activateHelperButtons()
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
//    toggleAdViewVisible(false)
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
    self.activateHelperButtons()
    helperButtonView.hidden = remove
    bonusStreakLabel.hidden = remove
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
    GameStatus.status.resettingTiles = false
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
  
  
  
  
  
  
  
  
  
  
  
  
  
  //MARK: Leaderboards
  
  func showLeaderboards() {
    if GameStatus.status.gc_enabled {
      // show the leaderboards
      showLeaderboard()
    } else {
      // activate the leaderboards, then report the score
      authenticateLocalPlayer()
    }
  }
  
  //MARK: GameKit
  func authenticateLocalPlayer() {
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
    if let loginView = GameStatus.status.gc_login_view_controller where !GameStatus.status.gc_enabled {
      self.presentViewController(loginView, animated: true, completion: nil)
    } else {
      localPlayer.authenticateHandler = {(ViewController, error) -> Void in
        if((ViewController) != nil) {
          // 1 Show login if player is not logged in
          GameStatus.status.gc_login_view_controller = ViewController
          self.presentViewController(ViewController!, animated: true, completion: nil)
        } else if (localPlayer.authenticated) {
          // 2 Player is already euthenticated & logged in, load game center
          GameStatus.status.gc_enabled = true
          // Get the default leaderboard ID
          localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String?, error: NSError?) -> Void in
            if error != nil {
              print(error)
            } else {
              GameStatus.status.gc_leaderboard_id = leaderboardIdentifer!
              self.reportScore({ (done) in
                self.showLeaderboard()
              })
            }
          })
        } else {
          // 3 Game center is not enabled on the users device
          GameStatus.status.gc_enabled = false
          print("Local player could not be authenticated, disabling game center")
          //show some kind of warning saying authentication failed, giving retry and okay options?
          //        self.navigationController?.popViewControllerAnimated(true)
        }
      }
    }
  }
  
  func showLeaderboard() {
    let gcVC: GKGameCenterViewController = GKGameCenterViewController()
    gcVC.gameCenterDelegate = self
    gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
    gcVC.leaderboardIdentifier = GameStatus.status.gc_leaderboard_id
    self.presentViewController(gcVC, animated: true, completion: nil)
  }
  
  func reportScore(callback: (Bool) -> ()) {
    print("REPORT SCORE")
    if GameStatus.status.gc_enabled {
      let sScore = GKScore(leaderboardIdentifier: GameStatus.status.gc_leaderboard_id)
      sScore.value = Int64(GameStatus.status.score)
      
      GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError?) -> Void in
        if error != nil {
          print(error!.localizedDescription)
        } else {
          print("Score submitted")
        }
      })
    }
  }
  
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    //perhaps only if going to the leaderboard?? not to sign in?
  }
  
  
  
  //Mark Helpers
  func buttonPressed(sender: ButtonView) {
    print("Helper Button Pressed")
    if helperButtonViewEnabled && ProgressionManager.sharedManager.currentHelperPoints > 0 && GameStatus.status.gameActive && !GameStatus.status.resettingTiles {
      if sender == self.hideTileButtonView && showHide {
       gameView?.helperSelected(.Hide)
      } else if sender == self.revealTileButtonView && showReveal {
        gameView?.helperSelected(.Reveal)
      }
      activateHelperButtons()
//      gameView?.helperButtonPressed()
//      toggleHelperMode(true)
      // stop the clock, show pause button overlay
    }
  }
  
  var showRemove: Bool = false
  var showHide: Bool = false
  var showReveal: Bool = false
  
  func activateHelperButtons() {
    let points = ProgressionManager.sharedManager.currentHelperPoints
    guard let layout = gameView?.currentLayout, _ = layout.winningCombination, tileViews = gameView?.tileViews else { return }
    
    // need number of tiles to be based on ones not effected by hide or reveal. So hide
    // hide is number of extra tiles without already being hidden
    // revealed is number of solution indexes left that aren't already revealed
    let hides = tileViews.filter({!$0.partOfSolution && $0.active && !$0.drawnIncorrect})
    let reveals = tileViews.filter({$0.partOfSolution && !$0.drawnCorrect})
    
    showHide = points >= 1 && hides.count > 0
    showReveal = points >= 3 && reveals.count > 1
    
    revealTileButtonView.togglePressed(!showReveal)
    hideTileButtonView.togglePressed(!showHide)
    revealTileButtonView.toggleActive(showReveal)
    hideTileButtonView.toggleActive(showHide)
    
    if points != 0 {
      let revA = Int(points / 3)
      let hideA = points
      
      revealTileIndicator.text = "\(revA) AVAILABLE"
      hideTileIndicator.text = "\(hideA) AVAILABLE"
    } else {
      revealTileIndicator.text = "0 AVAILABLE"
      hideTileIndicator.text = "0 AVAILABLE"
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
        self.timeLabel.transform = CGAffineTransformMakeScale(1.1, 1.1)
        self.scoreLabel.transform = CGAffineTransformMakeScale(1.05, 1.05)
      }) { (done) in
        UIView.animateWithDuration(self.tutorialBlinkTime, animations: {
          self.timeLabel.transform = CGAffineTransformIdentity
          self.scoreLabel.transform = CGAffineTransformIdentity
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
        self.revealTileButtonView.transform = CGAffineTransformMakeScale(1.08, 1.08)
        self.helperButtonViewIndicator.transform = CGAffineTransformMakeScale(1.08, 1.08)
        self.hideTileButtonView.transform = CGAffineTransformMakeScale(1.08, 1.08)
//        self.helperButtonView.transform = CGAffineTransformMakeScale(1.08, 1.08)
//        self.revealTileLabel.transform = CGAffineTransformMakeScale(1.08, 1.08)
      }) { (done) in
        UIView.animateWithDuration(self.tutorialBlinkTime, animations: {
          self.bonusStreakLabel.transform = CGAffineTransformIdentity
          self.revealTileButtonView.transform = CGAffineTransformIdentity
          self.helperButtonViewIndicator.transform = CGAffineTransformIdentity
          self.hideTileButtonView.transform = CGAffineTransformIdentity
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
    self.bonusStreakLabel.hidden = !on
    if on {
      blinkHelperPoints()
      self.tutorialBlinkingTimer = NSTimer.scheduledTimerWithTimeInterval(tutorialTimerTime, target: self, selector: #selector(ViewController.blinkHelperPoints), userInfo: nil, repeats: true)
    }
  }
  
  func setTutorialLabelText(text: String?) {
    if let text = text {
      self.helperButtonView.hidden = true
      self.bonusStreakLabel.hidden = true
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
    self.bonusStreakLabel.hidden = hide
  }
  
  func toggleAdViewVisible(visible: Bool) {
    if visible {
      let deviceIdiom = UIScreen.mainScreen().traitCollection.userInterfaceIdiom
      if deviceIdiom == .Pad {
//        self.layer.borderWidth = 3
      } else {
        
      }
      if self.adView.hidden {
        //      .kGADAdSizeBanner
        adView.adSize = kGADAdSizeSmartBannerPortrait
        adView.adUnitID = "ca-app-pub-2768090392054119/6062392781"
        adView.rootViewController = self
        let request = DFPRequest()
        adView.loadRequest(request)
      }
        adView.hidden = false
    } else {
      adView.hidden = true
    }
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
  
  @IBAction func muteButtonPressed(sender: AnyObject) {
    SoundManager.defaultManager.muted = !SoundManager.defaultManager.muted
    if SoundManager.defaultManager.muted {
      self.muteButton.setImage(ThemeHelper.defaultHelper.soundOffImage, forState: .Normal)
    } else {
      SoundManager.defaultManager.loadSoundFiles()
      self.muteButton.setImage(ThemeHelper.defaultHelper.soundOnImage, forState: .Normal)
    }
  }
}

