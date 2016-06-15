//
//  HelperPointViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class HelperPointViewController: UIViewController, ButtonDelegate {
  
  @IBOutlet weak var removeHelperTextLabel: UILabel!
  @IBOutlet weak var revealHelperTextLabel: UILabel!
  @IBOutlet weak var hideHelperTextLabel: UILabel!
  
  @IBOutlet weak var revealTileHelperView: ButtonView!
  @IBOutlet weak var hideTileHelperView: ButtonView!
  @IBOutlet weak var removeOperationHelperView: ButtonView!
  
  @IBOutlet weak var hideTileHelperIndicator: UILabel!
  @IBOutlet weak var revealTileHelperIndicator: UILabel!
  @IBOutlet weak var removeOperationHelperIndicator: UILabel!
  
  var showReveal = false
  var showHide = false
  var showRemove = false
  
  var backButtonEnabled = true
  
  var gameViewController: GameViewController?
  var delegate: GameViewDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupHelperButtons()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    delegate?.deactivateHelperPointButton(false, deactivate: true)
    activateHelperButtons()
    super.viewWillAppear(true)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(true)
  }
  
  func setupHelperButtons() {
    revealTileHelperView.becomeButtonForGameView(self, label: revealHelperTextLabel, delegate: self)
    hideTileHelperView.becomeButtonForGameView(self, label: hideHelperTextLabel, delegate: self)
    removeOperationHelperView.becomeButtonForGameView(self, label: removeHelperTextLabel, delegate: self)
  }
  
  func activateHelperButtons() {
    let points = ProgressionManager.sharedManager.currentHelperPoints
    guard let layout = gameViewController?.currentLayout, _ = layout.winningCombination else { return }
    delegate?.setHelperPoints(points, callback: { (done) in })
    // need to know the index of all of th
    showRemove = points >= 2 && ProgressionManager.sharedManager.multipleOperationsDisplayActive
    showHide = points >= 1 && ProgressionManager.sharedManager.numberOfExtraTiles > 0
    showReveal = points >= 3
    
    revealTileHelperView.togglePressed(!showReveal)
    removeOperationHelperView.togglePressed(!showRemove)
    hideTileHelperView.togglePressed(!showHide)
    revealTileHelperView.toggleActive(showReveal)
    removeOperationHelperView.toggleActive(showRemove)
    hideTileHelperView.toggleActive(showHide)
    
    if points != 0 {
      let revA = Int(points / 3)
      let hideA = points
      let remA = Int(points / 2)
      
      revealTileHelperIndicator.text = "\(revA) AVAILABLE"
      hideTileHelperIndicator.text = "\(hideA) AVAILABLE"
      removeOperationHelperIndicator.text = "\(remA) AVAILABLE"
    } else {
      revealTileHelperIndicator.text = "0 AVAILABLE"
      hideTileHelperIndicator.text = "0 AVAILABLE"
      removeOperationHelperIndicator.text = "0 AVAILABLE"
    }
    
  }
  
  func buttonPressed(sender: ButtonView) {
    if sender == revealTileHelperView {
      revealTileSelected()
    }
    if sender == hideTileHelperView {
      hideTileSelected()
    }
    if sender == removeOperationHelperView {
      removeOperationSelected()
    }
  }

  
  func revealTileSelected() {
    if showReveal {
      gameViewController?.helperSelected(.Reveal)
      self.navigationController?.popViewControllerAnimated(true)
      delegate?.toggleHelperMode(false)
    }
  }
  
  func removeOperationSelected() {
    if showRemove {
      gameViewController?.helperSelected(.Remove)
      self.navigationController?.popViewControllerAnimated(true)
      delegate?.toggleHelperMode(false)
    }
  }
  
  func hideTileSelected() {
    if showHide {
      gameViewController?.helperSelected(.Hide)
      self.navigationController?.popViewControllerAnimated(true)
      delegate?.toggleHelperMode(false)
    }
    self.backButtonEnabled = true
    self.hideButtonFlashTimer?.invalidate()
    self.hideButtonFlashTimer = nil
  }
  
  @IBAction func helpButtonPressed(sender: AnyObject) {
    self.performSegueWithIdentifier("showHelpSegue", sender: self)
  }
  
  @IBAction func backToGameButtonPressed(sender: AnyObject) {
    if backButtonEnabled {
      GameStatus.status.gameActive = true
      delegate?.deactivateHelperPointButton(false, deactivate: false)
      delegate?.togglePaused(false)
      self.navigationController?.popViewControllerAnimated(true)
    }
  }
  
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? HelperHelpViewController {
      vc.helperController = self
    }
   }
  
  
  
  // MARK: Tutorial
  var hideButtonFlashTimer: NSTimer?
  
  func flashHideButton() {
    UIView.animateWithDuration(0.3, animations: { 
      self.hideHelperTextLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)
      }) { (done) in
        self.hideHelperTextLabel.transform = CGAffineTransformIdentity
    }
  }
  
  func setHideToFlashing() {
    self.backButtonEnabled = false
    hideButtonFlashTimer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: #selector(HelperPointViewController.flashHideButton), userInfo: nil, repeats: true)
  }

}
