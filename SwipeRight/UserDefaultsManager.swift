//
//  UserDefaultsManager.swift
//  SwipeRight!
//
//  Created by Matthew Barth on 6/22/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit


class UserDefaultsManager {
  
  static var sharedManager = UserDefaultsManager()
  
  func getObjectForKey(key: String) -> AnyObject? {
    if let keychain = NSUserDefaults.standardUserDefaults().objectForKey("saved") as? Dictionary<String, AnyObject>, value = keychain[key] as? Int {
      return value
    } else {
      return nil
    }
  }
  
  func setValueAtKey(key: String, value: AnyObject) {
    var saved: Dictionary<String, AnyObject> = [key: value]
    if let savedSaved = NSUserDefaults.standardUserDefaults().objectForKey("saved") as? Dictionary<String, AnyObject> {
      saved = savedSaved
    }
    saved[key] = value
    NSUserDefaults.standardUserDefaults().setObject(saved, forKey: "saved")
  }
  
}