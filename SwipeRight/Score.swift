//
//  Score.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

class Score: NSObject {
  var user_id: String?
  var value: Int?
  var date: Double?
  
  static func scoreFromJson(json: jsonObject) -> Score {
    let score = Score()
    score.user_id = json["user_id"] as? String
    score.value = json["value"] as? Int
    score.date = json["date"] as? Double
    return score
  }
}