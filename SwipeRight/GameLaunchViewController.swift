//
//  GameLaunchViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

//ALSO MANAGES THE TUTORIAL (Dont have room on any of the others really...)
class GameLaunchViewController: UIViewController, ButtonDelegate {
  
  @IBOutlet weak var gameOverLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var highScoreLabel: UILabel!
  @IBOutlet weak var beginButtonView: ButtonView!
  @IBOutlet weak var beginButtonLabel: UILabel!
  
  var gameViewController: GameViewController?
  var containerView: UIView?
  var delegate: GameViewDelegate?
  
  var shouldPlayImmediately: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    beginButtonView.becomeButtonForGameView(self, label: beginButtonLabel, delegate: self)
    self.view.backgroundColor = ThemeHelper.defaultHelper.sw_gameview_background_color
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLayoutSubviews() {
    if shouldPlayImmediately {
      dispatch_async(dispatch_get_main_queue()) {
        self.performSegueWithIdentifier("showGameController", sender: self)
      }
      shouldPlayImmediately = false
    }
  }
  
  func buttonPressed(sender: ButtonView) {
    dispatch_async(dispatch_get_main_queue()) {
      self.performSegueWithIdentifier("showGameController", sender: self)
    }
  }
  
  func gameOver(score: Int, highScore: Bool) {
    self.gameOverLabel.hidden = false
    self.scoreLabel.text = "SCORE: \(score)"
    self.scoreLabel.hidden = false
    self.beginButtonView.hidden = false
    if highScore {
      print("HIGH SCORE RECOGNIZED")
      highScoreLabel.text = "NEW HIGH SCORE: \(score)"
      self.highScoreLabel.hidden = false
    }
    self.navigationController?.popToRootViewControllerAnimated(false)
  }
  
  
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showGameController" {
      if let vc = segue.destinationViewController as? GameViewController {
        delegate?.setGameViewController(vc)
        self.gameViewController = vc
        vc.delegate = delegate
        vc.containerView = containerView
      }
    }
  }
  
  
  
  //MARK: Tutorial
  
  func beginTutorial() {
    
  }
  
}
