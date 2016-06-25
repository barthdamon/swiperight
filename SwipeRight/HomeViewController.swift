//
//  HomeViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit
import GameKit

class HomeViewController: UIViewController, ButtonDelegate, GKGameCenterControllerDelegate {
  
  @IBOutlet weak var firstTimeView: UIView!
  @IBOutlet weak var logoView: UIImageView!
  @IBOutlet weak var firstTimeButton: UIButton!
  @IBOutlet weak var beginGameButtonView: ButtonView!
  @IBOutlet weak var leaderboardsButton: UIButton!
  @IBOutlet weak var removeAdsButton: UIButton!
  
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
    leaderboardsButton.alpha = 0
    removeAdsButton.alpha = 0
    if GameStatus.status.gc_enabled {
      authenticateLocalPlayer()
    }
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    UIView.animateWithDuration(0.5) { 
      self.beginGameButtonView.alpha = 1
      self.firstTimeButton.alpha = 1
      self.logoView.alpha = 1
      self.leaderboardsButton.alpha = 1
      self.removeAdsButton.alpha = 1
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
  
  @IBAction func leaderboardsButtonPressed(sender: AnyObject) {
    print("Leaderboards Pressed")
    if GameStatus.status.gc_enabled {
      showLeaderboard()
    } else {
      authenticateLocalPlayer()
    }
  }
  
  @IBAction func removeAdsButtonPressed(sender: AnyObject) {
    print("Remove Ads Pressed")
    
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
  
  
  
  
  //MARK: GameKit
  func authenticateLocalPlayer() {
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
    
    localPlayer.authenticateHandler = {(ViewController, error) -> Void in
      if((ViewController) != nil) {
        // 1 Show login if player is not logged in
        self.presentViewController(ViewController!, animated: true, completion: nil)
      } else if (localPlayer.authenticated) {
        // 2 Player is already euthenticated & logged in, load game center
        // Get the default leaderboard ID
        localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String?, error: NSError?) -> Void in
          if error != nil {
            print(error)
          } else {
            GameStatus.status.gc_leaderboard_id = leaderboardIdentifer!
            if !GameStatus.status.gc_enabled {
              self.showLeaderboard()
            }
            GameStatus.status.gc_enabled = true
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
  
  func showLeaderboard() {
    let gcVC: GKGameCenterViewController = GKGameCenterViewController()
    gcVC.gameCenterDelegate = self
    gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
    gcVC.leaderboardIdentifier = GameStatus.status.gc_leaderboard_id
    self.presentViewController(gcVC, animated: true, completion: nil)
  }
  
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    //perhaps only if going to the leaderboard?? not to sign in?
  }
}
