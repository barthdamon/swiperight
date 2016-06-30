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
  
  @IBOutlet weak var noButton: UIButton!
  @IBOutlet weak var yesButton: UIButton!
  @IBOutlet weak var helperExplanationView: UITextView!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var continueButton: UIButton!
  
  var delegate: GameViewDelegate?
  var gameViewController: GameViewController?
  var fromPointController: Bool = true
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setForMode()
    helperExplanationView.selectable = false
    // Do any additional setup after loading the view.
  }
  
  override func viewDidLayoutSubviews() {
    self.helperExplanationView.setContentOffset(CGPointZero, animated: false)
  }
  
  func setForMode() {
    let isTutorial = GameStatus.status.gameMode == .Tutorial && !fromPointController
    self.continueButton.hidden = !isTutorial
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
      self.setExplanationText("Welcome! Press continue to learn how to play...")
    case 1:
      self.setExplanationText("The goal is to find three tiles adjacent or diagonal to each other that complete a mathematical equation.\n\nSwipe the tiles from the start of the equation to the end to score a point.")
    case 2:
      // (really stage 3)
      delegate?.setBlinkingTimerOn(true)
      self.setExplanationText("Every equation you swipe correctly adds five seconds to the countdown timer. \n\nCorrect equations earn you one point, but if you swipe incorrectly you lose a point.")
      GameStatus.status.tutorialStage += 1
    case 4:
      self.setExplanationText("There is only ONE active equation. \n\nActive operations and the board background color indicate the operation of the current equation.")
    case 5:
      GameStatus.status.tutorialStage += 1
      setupForTutorialStage()
//      self.helperExplanationView.text = "At higher levels two operations may become active, but only one correct equation will be on the board..."
    case 6:
      // (really stage 7)
      delegate?.setBlinkingHelperPointsOn(true, withStreaks: true, hideStreaks: false)
      self.setExplanationText("For every three equations you complete in a row you get an ability point, which help you find the equation.\n\nHiding an extra tile uses up one ability point, revealing a correct tile uses up three ability points.")
      GameStatus.status.tutorialStage += 1
//      performActionsForTutorialStage()
    case 8:
      // (really the final stage)
      self.setExplanationText("Ready for the real thing?")
      self.continueButton.hidden = true
      self.yesButton.hidden = false
      self.noButton.hidden = false
    default:
      break
    }
  }
  
  func setExplanationText(text: String) {
    helperExplanationView.selectable = true
    helperExplanationView.text = text
    helperExplanationView.selectable = false
  }
  
  func performActionsForTutorialStage() {
    switch GameStatus.status.tutorialStage {
    case 0:
      GameStatus.status.tutorialStage += 1
      setupForTutorialStage()
    case 1:
      GameStatus.status.tutorialStage += 1
      delegate?.setTutorialLabelText("Press and hold your finger to the first tile, then swipe!")
      gameViewController?.setGameViewForTutorialStage()
    case 3:
      GameStatus.status.tutorialStage += 1
      setupForTutorialStage()
      delegate?.setBlinkingTimerOn(false)
      delegate?.setBlinkingOperationsOn(true)
    case 4:
      GameStatus.status.tutorialStage += 1
      delegate?.setBlinkingOperationsOn(false)
      gameViewController?.setGameViewForTutorialStage()
    case 7:
      //show gameboard to do helper points
      GameStatus.status.tutorialStage += 1
      delegate?.setBlinkingHelperPointsOn(false, withStreaks: false, hideStreaks: true)
      gameViewController?.setGameViewForTutorialStage()
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
  
  @IBAction func yesButtonPressed(sender: AnyObject) {
    delegate?.launchForEndTutorial("Wohoo! you got this!")
  }
  
  @IBAction func noButtonPressed(sender: AnyObject) {
    delegate?.launchForEndTutorial("Don't worry, you got this!")
  }
  
  @IBAction func continueButtonPressed(sender: AnyObject) {
    // show the next onboarding info
    performActionsForTutorialStage()
//    self.navigationController?.popViewControllerAnimated(true)
  }
}
