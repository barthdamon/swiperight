//
//  HomeViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
  
  @IBOutlet weak var firstTimeButton: UIButton!
  @IBOutlet weak var howToPlayButtonView: UIView!
  @IBOutlet weak var beginGameButtonView: UIView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    configureBackground()
    setupButtons()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func configureBackground() {
    let firstColor = ThemeHelper.defaultHelper.sw_blue_color
    let secondColor = ThemeHelper.defaultHelper.sw_green_color
    let gradientLayer = CAGradientLayer.verticalGradientLayerForBounds(self.view.bounds, colors: (start: firstColor, end: secondColor), rounded: false)
    self.view.layer.hidden = false
    self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
  }
  
  func setupButtons() {
    beginGameButtonView.becomeButtonForGameView(self, selector: #selector(HomeViewController.playButtonPressed(_:)))
    let lineView = UIView(frame: CGRectMake(0, firstTimeButton.frame.height, firstTimeButton.frame.size.width, 1))
    lineView.backgroundColor=UIColor.whiteColor()
    firstTimeButton.addSubview(lineView)
//    howToPlayButtonView.becomeButtonForGameView(self, selector: #selector(HomeViewController.howToButtonPressed(_:)))
//    leaderboardsButtonView.becomeButtonForGameView(self, selector: #selector(HomeViewController.leaderboardsButtonPressed(_:)))
//    self.leaderboardsButtonView.alpha = 0.4
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
  
  func playButtonPressed(sender: AnyObject) {
    GameStatus.status.selectedMode = .Ranked
    self.performSegueWithIdentifier("showGameSegue", sender: self)
  }
  
  @IBAction func howToButtonPressed(sender: AnyObject) {
    self.performSegueWithIdentifier("howToSegue", sender: self)
  }

}
