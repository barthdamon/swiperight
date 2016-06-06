//
//  HelperPointViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class HelperPointViewController: UIViewController {
  
  @IBOutlet weak var removeHelperTextLabel: UILabel!
  @IBOutlet weak var revealHelperTextLabel: UILabel!
  @IBOutlet weak var hideHelperTextLabel: UILabel!
  @IBOutlet weak var revealTileHelperView: UIView!
  @IBOutlet weak var hideTileHelperView: UIView!
  @IBOutlet weak var removeOperationHelperView: UIView!
  @IBOutlet weak var hideTileHelperIndicator: UILabel!
  @IBOutlet weak var revealTileHelperIndicator: UILabel!
  @IBOutlet weak var removeOperationHelperIndicator: UILabel!
  
  var showReveal = false
  var showHide = false
  var showRemove = false
  
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
  }
  
  override func viewWillDisappear(animated: Bool) {
    delegate?.deactivateHelperPointButton(false, deactivate: false)
  }
  
  func setupHelperButtons() {
    revealTileHelperView.becomeButtonForGameView(self, selector: #selector(HelperPointViewController.revealTileSelected))
    hideTileHelperView.becomeButtonForGameView(self, selector: #selector(HelperPointViewController.hideTileSelected))
    removeOperationHelperView.becomeButtonForGameView(self, selector: #selector(HelperPointViewController.removeOperationSelected))
  }
  
  func activateHelperButtons() {
    let points = ProgressionManager.sharedManager.currentHelperPoints
    guard let layout = gameViewController?.currentLayout, _ = layout.winningCombination else { return }
    delegate?.setHelperPoints(points)
    // need to know the index of all of th
    showRemove = points >= 2
    showHide = points >= 1
    showReveal = points >= 3
    // need the active operation of the current solution and all of the number indexes
    if showRemove && ProgressionManager.sharedManager.multipleOperationsDisplayActive  {
      removeHelperTextLabel.alpha = 1
      removeOperationHelperView.layer.shadowRadius = 10
    } else {
      removeHelperTextLabel.alpha = 0.4
      removeOperationHelperView.layer.shadowRadius = 0
    }
    
    if showHide && ProgressionManager.sharedManager.numberOfExtraTiles > 0 {
      hideHelperTextLabel.alpha = 1
      hideTileHelperView.layer.shadowRadius = 10
    } else {
      hideHelperTextLabel.alpha = 0.4
      hideTileHelperView.layer.shadowRadius = 0
    }
    
    if showReveal {
      revealHelperTextLabel.alpha = 1
      revealTileHelperView.layer.shadowRadius = 10
    } else {
      revealHelperTextLabel.alpha = 0.4
      revealTileHelperView.layer.shadowRadius = 0
    }
    
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
  }
  
  
  @IBAction func backToGameButtonPressed(sender: AnyObject) {
    self.navigationController?.popViewControllerAnimated(true)
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
