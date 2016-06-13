//
//  HelperHelpViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/8/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class HelperHelpViewController: UIViewController {
  
  var helperController: HelperPointViewController?
  
  @IBOutlet weak var helperExplanationView: UITextView!
  @IBOutlet weak var tutorialTextView: UITextView!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var continueButton: UIButton!
  
  var delegate: GameViewDelegate?
  var gameViewController: GameViewController?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setForMode()
    // Do any additional setup after loading the view.
  }
  
  func setForMode() {
    let isTutorial = GameStatus.status.gameMode == .Tutorial
    self.tutorialTextView.hidden = !isTutorial
    self.continueButton.hidden = !isTutorial
    self.helperExplanationView.hidden = isTutorial
    self.backButton.hidden = isTutorial
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(true)
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
  
  @IBAction func backToHelpersButtonPressed(sender: AnyObject) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func continueButtonPressed(sender: AnyObject) {
    // show the next onboarding info
    self.navigationController?.popViewControllerAnimated(true)
  }
}
