//
//  HelperPointViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class HelperPointViewController: UIViewController, ButtonDelegate {
  
  @IBOutlet weak var backButton: UIButton!
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
  var rightSwipe: UISwipeGestureRecognizer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if GameStatus.status.gameMode == .Tutorial {
      delegate?.setTutorialLabelText("Hide a tile with your ability point!")
      self.backButton.hidden = true
      if let _ = rightSwipe {
        self.view.removeGestureRecognizer(rightSwipe!)
        self.rightSwipe = nil
      }
    } else {
      delegate?.toggleAdViewVisible(true)
      activateGestureRecognizers()
      // show an add
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(animated: Bool) {
    delegate?.toggleHelperMode(false)
    super.viewWillDisappear(true)
  }
  
  override func viewWillAppear(animated: Bool) {
    delegate?.deactivateHelperPointButton(false, deactivate: true)
//    activateHelperButtons()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
//    activateHelperButtons()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setupHelperButtons()
    activateHelperButtons()
  }
  
  func activateGestureRecognizers() {
    if let _ = rightSwipe {
      return
    } else {
      self.rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(HelperPointViewController.backToGameButtonPressed(_:)))
      rightSwipe?.direction = .Right
      self.view.addGestureRecognizer(rightSwipe!)
    }
  }
  
  func setupHelperButtons() {
    revealTileHelperView.becomeButtonForGameView(self, label: revealHelperTextLabel, delegate: self)
    hideTileHelperView.becomeButtonForGameView(self, label: hideHelperTextLabel, delegate: self)
    removeOperationHelperView.becomeButtonForGameView(self, label: removeHelperTextLabel, delegate: self)
  }
  
  func activateHelperButtons() {
    let points = ProgressionManager.sharedManager.currentHelperPoints
    guard let layout = gameViewController?.currentLayout, _ = layout.winningCombination, tileViews = gameViewController?.tileViews else { return }
    
    // need number of tiles to be based on ones not effected by hide or reveal. So hide
    // hide is number of extra tiles without already being hidden
    // revealed is number of solution indexes left that aren't already revealed
    let hides = tileViews.filter({!$0.partOfSolution && $0.active && !$0.drawnIncorrect})
    let reveals = tileViews.filter({$0.partOfSolution && !$0.drawnCorrect})
    
    showRemove = points >= 2 && layout.operations.count > 1 && ProgressionManager.sharedManager.multipleOperationsDisplayActive
    showHide = points >= 1 && hides.count > 0
    showReveal = points >= 3 && reveals.count > 1
    
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
//      delegate?.toggleAdViewVisible(false)
      self.navigationController?.popViewControllerAnimated(true)
      delegate?.toggleHelperMode(false)
    }
  }
  
  func removeOperationSelected() {
    if showRemove {
      gameViewController?.helperSelected(.Remove)
//      delegate?.toggleAdViewVisible(false)
      self.navigationController?.popViewControllerAnimated(true)
      delegate?.toggleHelperMode(false)
    }
  }
  
  func hideTileSelected() {
    if showHide {
      delegate?.setTutorialLabelText(nil)
//      delegate?.toggleAdViewVisible(false)
      if GameStatus.status.gameMode == .Tutorial {
        gameViewController?.tutorialTimeForHelper = false
        gameViewController?.backFromTutorialHelper = true
        gameViewController?.view.userInteractionEnabled = true
      }
      gameViewController?.helperSelected(.Hide)
      self.navigationController?.popViewControllerAnimated(true)
      delegate?.toggleHelperMode(false)
    }
    self.backButtonEnabled = true
//    self.hideButtonFlashTimer?.invalidate()
//    self.hideButtonFlashTimer = nil
  }
  
  @IBAction func backToGameButtonPressed(sender: AnyObject) {
    if backButtonEnabled {
      GameStatus.status.gameActive = true
//      delegate?.toggleAdViewVisible(false)
      delegate?.deactivateHelperPointButton(false, deactivate: false)
      if GameStatus.status.gameMode == .Standard {
        delegate?.togglePaused(false)
      }
      delegate?.toggleHelperMode(false)
      self.navigationController?.popViewControllerAnimated(true)
    }
  }
  
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? HelperHelpViewController {
      vc.helperController = self
    }
   }
  
}
