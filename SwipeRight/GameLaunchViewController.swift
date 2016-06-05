//
//  GameLaunchViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class GameLaunchViewController: UIViewController {
  
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var highScoreLabel: UILabel!
  @IBOutlet weak var beginButtonView: UIView!
  
  var gameViewController: GameViewController?
  var delegate: GameViewDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    beginButtonView.becomeButtonForGameView(self, selector: #selector(GameLaunchViewController.beginButtonSelected(_:)))
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func beginButtonSelected(sender: UIGestureRecognizer) {
    self.performSegueWithIdentifier("showGameController", sender: self)
  }
  
  
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showGameController" {
      if let vc = segue.destinationViewController as? GameViewController {
        delegate?.setGameViewController(vc)
        self.gameViewController = vc
        vc.delegate = delegate
      }
    }
  }
  
}
