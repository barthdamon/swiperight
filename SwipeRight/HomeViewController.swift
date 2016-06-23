//
//  HomeViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, ButtonDelegate {
  
  @IBOutlet weak var firstTimeView: UIView!
  @IBOutlet weak var logoView: UIImageView!
  @IBOutlet weak var firstTimeButton: UIButton!
  @IBOutlet weak var beginGameButtonView: ButtonView!
  
  @IBOutlet weak var beginGameLabel: UILabel!
  
  var lineView: UIView?
  
  var firstTime: Bool {
    get {
      if let first = UserDefaultsManager.sharedManager.getObjectForKey("firstTime") as? Bool {
        return first
      } else {
        return true
      }
    }
    set (newValue) {
      UserDefaultsManager.sharedManager.setValueAtKey("firstTime", value: newValue)
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    MultipleHelper.defaultHelper.initializeCombinations()
    beginGameButtonView.alpha = 0
    firstTimeButton.alpha = 0
    logoView.alpha = 0
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    UIView.animateWithDuration(0.5) { 
      self.beginGameButtonView.alpha = 1
      self.firstTimeButton.alpha = 1
      self.logoView.alpha = 1
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setupButtons()
  }

  
  func setupButtons() {
    beginGameButtonView.becomeButtonForGameView(self, label: beginGameLabel, delegate: self)
    if self.lineView == nil {
      lineView = UIView(frame: CGRectMake(0, firstTimeButton.frame.height, firstTimeButton.frame.size.width, 1))
      lineView?.backgroundColor=UIColor.blackColor()
      firstTimeButton.addSubview(lineView!)
//      lineView?.alpha = 0.1
    }
//    howToPlayButtonView.becomeButtonForGameView(self, selector: #selector(HomeViewController.howToButtonPressed(_:)))
//    leaderboardsButtonView.becomeButtonForGameView(self, selector: #selector(HomeViewController.leaderboardsButtonPressed(_:)))
//    self.leaderboardsButtonView.alpha = 0.4
  }
  
  
  func toggleUnderlineAlpha(dark: Bool) {
    if dark {
      UIView.animateWithDuration(0.1, animations: {
        self.lineView?.alpha = 1
      })
    } else {
      lineView?.alpha = 0.1
    }
  }
  
  func presentFirstTimeOptions() {
    self.firstTimeView.layer.shadowColor = ThemeHelper.defaultHelper.sw_shadow_color.CGColor
    self.firstTimeView.layer.shadowRadius = 10
    self.firstTimeView.layer.shadowOffset = CGSizeZero
    self.firstTimeView.layer.shadowOpacity = 0.3
    self.firstTimeView.hidden = false
    firstTime = false
  }
  

   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showGameSegue" {
      if let vc = segue.destinationViewController as? ViewController {
        vc.shouldPlayImmediately = true
      }
    }
   }
  
  func leaderboardsButtonPressed(sender: AnyObject) {
    print("show leaderboards")
//    self.performSegueWithIdentifier("showLeaderboard", sender: self)
  }

  @IBAction func bePreparedButtonPressed(sender: AnyObject) {
    self.firstTimeView.hidden = true
    sendToTutorial()
  }
  
  @IBAction func skipTutorialButtonPressed(sender: AnyObject) {
    self.firstTimeView.hidden = true
    sendToGame()
  }
  
  func buttonPressed(sender: ButtonView) {
    if firstTime {
      presentFirstTimeOptions()
    } else {
      sendToGame()
    }
  }
  
  func sendToGame() {
    GameStatus.status.gameMode = .Standard
    self.performSegueWithIdentifier("showGameSegue", sender: self)
  }
  
  func sendToTutorial() {
    GameStatus.status.gameMode = .Tutorial
    self.performSegueWithIdentifier("showGameSegue", sender: self)
  }
  
  @IBAction func howToButtonPressed(sender: AnyObject) {
    toggleUnderlineAlpha(true)
    sendToTutorial()
  }
  
  @IBAction func howToButtonDown(sender: AnyObject) {
    toggleUnderlineAlpha(false)
  }
  @IBAction func howToButtonCancel(sender: AnyObject) {
    toggleUnderlineAlpha(true)
  }
  @IBAction func howToButtonExited(sender: AnyObject) {
    toggleUnderlineAlpha(true)
  }
}
