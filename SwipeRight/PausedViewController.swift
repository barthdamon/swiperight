//
//  PausedViewController.swift
//  SwipeRight!
//
//  Created by Matthew Barth on 7/20/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class PausedViewController: UIViewController, ButtonDelegate {
  
  @IBOutlet weak var exitGameTextLabel: UILabel!
  @IBOutlet weak var resumeGameTextLabel: UILabel!
  @IBOutlet weak var exitGameButtonView: ButtonView!
  @IBOutlet weak var resumeButtonView: ButtonView!
  @IBOutlet weak var pausedLabel: UILabel!
  
  var delegate: GameViewDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setupMenuButtons()
  }
  
  func setupMenuButtons() {
    exitGameButtonView.becomeButtonForGameView(self, label: exitGameTextLabel, delegate: self)
    resumeButtonView.becomeButtonForGameView(self, label: resumeGameTextLabel, delegate: self)
  }
  
  func buttonPressed(sender: ButtonView) {
    print("Paused Button Pressed")
    if sender == exitGameButtonView {
      // delegate dismiss
      self.delegate?.exitGame()
    }
    
    if sender == resumeButtonView {
      self.delegate?.togglePaused(false)
      self.navigationController?.popViewControllerAnimated(true)
      // delegate toggle pause
    }
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
