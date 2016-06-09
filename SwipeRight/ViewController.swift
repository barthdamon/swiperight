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
  
  @IBOutlet weak var gameContainerView: UIView!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var highScoreLabel: UILabel!
  @IBOutlet weak var operationIndicatorView: UIView!
  @IBOutlet weak var divideView: UIImageView!
  @IBOutlet weak var multiplyView: UIImageView!
  @IBOutlet weak var subtractView: UIImageView!
  @IBOutlet weak var addView: UIImageView!
  
  @IBOutlet weak var helperButtonView: UIView!
  @IBOutlet weak var helperButtonViewIndicator: UILabel!
  
  @IBOutlet weak var helperStreakLabel: UILabel!
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
  var helperButtonViewEnabled: Bool = true
  
  //Game Client
  var beginButton: UIButton?
  //  var resetButton: UIButton?
  var helperButton: UIButton?
  
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
  var gameLaunchView: GameLaunchViewController?
  var gameView: GameViewController?
  var countdownOverlayView: TileView?
  var viewWidth: CGFloat = 0
  var viewHeight: CGFloat = 0
  var operations: Array<Operation>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    timeLabel.adjustsFontSizeToFitWidth = true
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
  }
  
  func configureViewStyles() {
    gameContainerView.layer.shadowColor = ThemeHelper.defaultHelper.sw_gameview_shadow_color.CGColor
    gameContainerView.layer.shadowOpacity = 1
    gameContainerView.layer.shadowOffset = CGSizeZero
    gameContainerView.layer.shadowRadius = 2
    
    let firstColor = ThemeHelper.defaultHelper.sw_blue_color
    let secondColor = ThemeHelper.defaultHelper.sw_green_color
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
    helperStreakLabel.text = "HELPER STREAK: \(streak)/\(needed)"
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
  
  
  //MARK: HUD
  
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
    deactivateHelperPointButton(true, deactivate: false)
    timer?.invalidate()
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
    helperButtonView.becomeButtonForGameView(self, selector: #selector(ViewController.helperButtonPressed(_:)))
    //TOOD: Set helper button Target to gameView
    helperButtonViewIndicator.text = "\(0)"
    helperButtonViewIndicator.layer.cornerRadius = helperButtonViewIndicator.frame.width / 2
    helperButtonViewIndicator.clipsToBounds = true
    
  }
  
  func helperButtonPressed(sender: UIGestureRecognizer) {
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
    multiplyView?.image = multiplyImageGrayInactive
    divideView?.image = divideImageGrayInactive
    subtractView?.image = subtractImageGrayInactive
    addView?.image = addImageGrayInactive
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
  
  @IBAction func menuButtonPressed(sender: AnyObject) {
    print("Menu Button Pressed")
    GameStatus.status.gameActive = false
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "gameViewEmbed" {
      if let topNav = segue.destinationViewController as? UINavigationController, vc = topNav.topViewController as? GameLaunchViewController {
        vc.delegate = self
        self.gameLaunchView = vc
        vc.containerView = gameContainerView
      }
    }
  }
    
}

