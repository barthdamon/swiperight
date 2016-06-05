//
//  CurrentUser.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/31/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import Foundation

private let _info = CurrentUser()

class CurrentUser: NSObject {
  
  class var info: CurrentUser {
    return _info
  }
  
  var API = APIService.sharedService
  
  var highScore: Int {
    get {
      if let keychain = NSUserDefaults.standardUserDefaults().objectForKey("scores") as? Dictionary<String, AnyObject>, highScore = keychain["highScore"] as? Int {
        return highScore
      } else {
        return 0
      }
    }
    set (newValue) {
      let scores = [
        "highScore" : newValue
      ]
      NSUserDefaults.standardUserDefaults().setObject(scores, forKey: "scores")
    }
  }
  
  var model: User?
  var friends: Array<User>?
  //store to keychain and when called return from the keychain
  var authToken: String?
  let keychain = KeychainSwift()
  
  func token() -> String? {
    if let token = authToken {
      return token
    } else if let token = keychain.get("api_authtoken") {
      self.authToken = token
      NSNotificationCenter.defaultCenter().postNotificationName("userHasToken", object: nil, userInfo: nil)
      return token
    } else {
      NSNotificationCenter.defaultCenter().postNotificationName("noUserTokenFound", object: nil, userInfo: nil)
      return nil
    }
  }
  
  func storeToken(json: jsonObject, callback: (Bool) -> ()) {
    if let token = json["api_authtoken"] as? String {
      let stored = self.keychain.set(token, forKey: "api_authtoken")
      if stored {
        self.authToken = token
        NSNotificationCenter.defaultCenter().postNotificationName("userHasToken", object: nil, userInfo: nil)
        callback(true)
      } else {
        callback(false)
      }
    } else {
      callback(false)
    }
  }
  
  func newUser(params: jsonObject, callback: (Bool) -> ()) {
    API.post(params, authType: .Basic, url: "new"){ (res, err) in
      if let e = err {
        print("Error creating user: \(e)")
        callback(false)
      } else {
        if let json = res as? jsonObject {
          self.storeToken(json, callback: callback)
        } else {
          callback(false)
        }
      }
    }
  }
  
  func logIn(params:jsonObject, callback: (Bool) -> ()) {
    API.post(params, authType: .Basic, url: "login"){ (res, err) in
      if let e = err {
        print("Error logging in user: \(e)")
        callback(false)
      } else {
        if let json = res as? jsonObject {
          self.storeToken(json, callback: callback)
        } else {
          callback(false)
        }
      }
    }
  }
  
  func logOut() {
    keychain.delete("api_authtoken")
    NSNotificationCenter.defaultCenter().postNotificationName("userLoggedOut", object: nil, userInfo: nil)
  }
  
}