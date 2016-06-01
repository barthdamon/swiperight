//
//  User.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

class User: NSObject {
  
  //Info
  var _id: String?
  var name: String?
  var email: String?
  var username: String?
  
  static func userFromProfile(json: jsonObject) -> User {
    let user = User()
    user._id = json["_id"] as? String
    user.name = json["name"] as? String
    user.email = json["email"] as? String
    user.username = json["username"] as? String
    return user
  }


}