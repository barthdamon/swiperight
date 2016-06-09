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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewWillDisappear(animated: Bool) {
    helperController?.showingHelp = false
    super.viewWillDisappear(true)
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  @IBAction func backToHelpersButtonPressed(sender: AnyObject) {
    self.navigationController?.popViewControllerAnimated(true)
  }

}
