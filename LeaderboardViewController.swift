//
//  LeaderboardViewController.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit
import Foundation

enum Grouping: String {
  case Day = "day"
  case Week = "week"
  case Month = "month"
  case All = "all"
}

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var allButton: UIButton!
  @IBOutlet weak var monthButton: UIButton!
  @IBOutlet weak var weekButton: UIButton!
  @IBOutlet weak var dayButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  var currentGrouping: Grouping = .Day
  var scores: Array<Score> = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCurrentRankings(currentGrouping)
  }
  
  func loadCurrentRankings(grouping: Grouping) {
    APIService.sharedService.get(nil, authType: .Basic, url: "rankings/\(currentGrouping.rawValue)", callback: { (data, err) in
      if let e = err {
        print("Error: \(e)")
      } else if let json = data as? jsonObject, scoresJson = json["saved"] as? Array<jsonObject> {
        print("Scores: \(scoresJson)")
        scoresJson.forEach({ (scoreJson) in
          self.scores.append(Score.scoreFromJson(scoreJson))
        })
        self.reload()
      }
    })
  }
  
  @IBAction func dayButtonPressed(sender: AnyObject) {
  }
  @IBAction func weekButtonPressed(sender: AnyObject) {
  }
  @IBAction func monthButtonPressed(sender: AnyObject) {
  }
  @IBAction func allButtonPressed(sender: AnyObject) {
  }
  
  // MARK: UITableView Delegate Methods
  
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return scores.count
  }
  
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
}
