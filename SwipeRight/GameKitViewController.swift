//
//  GameKitViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/7/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class GameKitController: UIViewController, GKGameCenterControllerDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    authenticateLocalPlayer()
  }
  
  func authenticateLocalPlayer() {
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
    
    localPlayer.authenticateHandler = {(ViewController, error) -> Void in
      if((ViewController) != nil) {
        // 1 Show login if player is not logged in
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
            self.showLeaderboard()
          }
        })
      } else {
        // 3 Game center is not enabled on the users device
        GameStatus.status.gc_enabled = false
        print("Local player could not be authenticated, disabling game center")
        //show some kind of warning saying authentication failed, giving retry and okay options?
        self.navigationController?.popViewControllerAnimated(true)
      }
      
    }
    
  }
  
//  func submitScore(score: Int) {
//    let leaderboardID = gcDefaultLeaderBoard
//    let sScore = GKScore(leaderboardIdentifier: leaderboardID)
//    sScore.value = Int64(score)
//    
//    GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError?) -> Void in
//      if error != nil {
//        print(error!.localizedDescription)
//      } else {
//        print("Score submitted")
//      }
//    })
//  }
  
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    //perhaps only if going to the leaderboard?? not to sign in?
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  
  func showLeaderboard() {
    let gcVC: GKGameCenterViewController = GKGameCenterViewController()
    gcVC.gameCenterDelegate = self
    gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
    gcVC.leaderboardIdentifier = GameStatus.status.gc_leaderboard_id
    self.presentViewController(gcVC, animated: true, completion: nil)
  }
}