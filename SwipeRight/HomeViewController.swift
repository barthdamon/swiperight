//
//  HomeViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  @IBAction func leaderboardsButtonPressed(sender: AnyObject) {
    self.performSegueWithIdentifier("showLeaderboard", sender: self)
  }
  @IBAction func settingsButtonPressed(sender: AnyObject) {
    if let _ = CurrentUser.info.token() {
      self.performSegueWithIdentifier("showProfile", sender: self)
    } else {
      self.performSegueWithIdentifier("showAuth", sender: self)
    }
  }
  @IBAction func rankedPlayButtonPressed(sender: AnyObject) {
    if let _ = CurrentUser.info.token() {
      GameStatus.status.selectedMode = .Ranked
      self.performSegueWithIdentifier("showGameSegue", sender: self)
    } else {
      self.performSegueWithIdentifier("showAuth", sender: self)
    }
  }
  @IBAction func standardPlayButtonPressed(sender: AnyObject) {
    GameStatus.status.selectedMode = .Standard
    self.performSegueWithIdentifier("showGameSegue", sender: self)
  }
  @IBAction func practiceButtonPressed(sender: AnyObject) {
    GameStatus.status.selectedMode = .Practice
    self.performSegueWithIdentifier("showGameSegue", sender: self)
  }
  
}
