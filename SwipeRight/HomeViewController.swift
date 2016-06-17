//
//  HomeViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, ButtonDelegate {
  
  @IBOutlet weak var logoView: UIImageView!
  @IBOutlet weak var firstTimeButton: UIButton!
  @IBOutlet weak var beginGameButtonView: ButtonView!
  
  @IBOutlet weak var beginGameLabel: UILabel!
  
  var lineView: UIView?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    MultipleHelper.defaultHelper.initializeCombinations()
    beginGameButtonView.alpha = 0
    firstTimeButton.alpha = 0
    logoView.alpha = 0
    // Do any additional setup after loading the view.
    configureBackground()
    setupButtons()
  }
  
  override func viewDidAppear(animated: Bool) {
    UIView.animateWithDuration(0.5) { 
      self.beginGameButtonView.alpha = 1
      self.firstTimeButton.alpha = 1
      self.logoView.alpha = 1
    }
  }
  
  
  func configureBackground() {
//    let firstColor = ThemeHelper.defaultHelper.sw_background_color
//    let secondColor = ThemeHelper.defaultHelper.sw_background_glow_color
//    let gradientLayer = CAGradientLayer.verticalGradientLayerForBounds(self.view.bounds, colors: (start: firstColor, end: secondColor), rounded: false)
//    self.view.layer.hidden = false
//    self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
  }
  
  func setupButtons() {
    beginGameButtonView.becomeButtonForGameView(self, label: beginGameLabel, delegate: self)
    lineView = UIView(frame: CGRectMake(0, firstTimeButton.frame.height, firstTimeButton.frame.size.width, 1))
    lineView?.backgroundColor=UIColor.blackColor()
    firstTimeButton.addSubview(lineView!)
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
  
  func buttonPressed(sender: ButtonView) {
    GameStatus.status.gameMode = .Standard
    self.performSegueWithIdentifier("showGameSegue", sender: self)
  }
  
  @IBAction func howToButtonPressed(sender: AnyObject) {
    GameStatus.status.gameMode = .Tutorial
    toggleUnderlineAlpha(true)
    self.performSegueWithIdentifier("showGameSegue", sender: self)
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
