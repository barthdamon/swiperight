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
    if isTutorial {
      setupForTutorialStage()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(true)
  }
  
  func setupForTutorialStage() {
    switch GameStatus.status.tutorialStage {
    case 0:
      self.tutorialTextView.text = "Find the three tiles adjacent or diagonal to each other that complete a mathematical equation."
    case 1:
      self.tutorialTextView.text = "Swipe the tiles from the start of the equation to the end to score a point."
    case 2:
      // (really stage 3)
      delegate?.setBlinkingTimerOn(true)
      self.tutorialTextView.text = "Every equation you swipe right adds five seconds to the countdown timer."
      GameStatus.status.tutorialStage += 1
    case 4:
      self.tutorialTextView.text = "There is only one active equation. Active operations indicate the operation of the equation."
    case 5:
      self.tutorialTextView.text = "At higher levels two operations become active to trick you, but there is still only one equation..."
    case 6:
      // (really stage 7)
      delegate?.setBlinkingHelperPointsOn(true)
      self.tutorialTextView.text = "For every three equations of an operation you swipe right in a row you get a bonus point."
      GameStatus.status.tutorialStage += 1
    default:
      break
    }
  }
  
  func performActionsForTutorialStage() {
    switch GameStatus.status.tutorialStage {
    case 0:
      GameStatus.status.tutorialStage += 1
      setupForTutorialStage()
    case 1:
      GameStatus.status.tutorialStage += 1
      gameViewController?.setGameViewForTutorialStage()
    case 3:
      GameStatus.status.tutorialStage += 1
      setupForTutorialStage()
      delegate?.setBlinkingTimerOn(false)
      delegate?.setBlinkingOperationsOn(true)
    case 4:
      GameStatus.status.tutorialStage += 1
      delegate?.setBlinkingOperationsOn(false)
      setupForTutorialStage()
    case 5:
      GameStatus.status.tutorialStage += 1
      gameViewController?.setGameViewForTutorialStage()
    case 7:
      //show gameboard to do helper points
      break
    default:
      break
    }
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
    performActionsForTutorialStage()
//    self.navigationController?.popViewControllerAnimated(true)
  }
}
