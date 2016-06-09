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
  
  var score: Int = 0 // Stores the score
  
  var gcEnabled = Bool() // Stores if the user has Game Center enabled
  var gcDefaultLeaderBoard = String() // Stores the default leaderboardID
  
  func authenticateLocalPlayer() {
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
    
    localPlayer.authenticateHandler = {(ViewController, error) -> Void in
      if((ViewController) != nil) {
        // 1 Show login if player is not logged in
        self.presentViewController(ViewController!, animated: true, completion: nil)
      } else if (localPlayer.authenticated) {
        // 2 Player is already euthenticated & logged in, load game center
        self.gcEnabled = true
        
        // Get the default leaderboard ID
        localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String?, error: NSError?) -> Void in
          if error != nil {
            print(error)
          } else {
            self.gcDefaultLeaderBoard = leaderboardIdentifer!
          }
        })
        
        
      } else {
        // 3 Game center is not enabled on the users device
        self.gcEnabled = false
        print("Local player could not be authenticated, disabling game center")
        print(error)
      }
      
    }
    
  }
  
  @IBAction func submitScore(sender: UIButton) {
    let leaderboardID = "LeaderboardID"
    let sScore = GKScore(leaderboardIdentifier: leaderboardID)
    sScore.value = Int64(score)
    
    GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError?) -> Void in
      if error != nil {
        print(error!.localizedDescription)
      } else {
        print("Score submitted")
        
      }
    })
  }
  
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  @IBAction func showLeaderboard(sender: UIButton) {
    let gcVC: GKGameCenterViewController = GKGameCenterViewController()
    gcVC.gameCenterDelegate = self
    gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
    gcVC.leaderboardIdentifier = "LeaderboardID"
    self.presentViewController(gcVC, animated: true, completion: nil)
  }
}