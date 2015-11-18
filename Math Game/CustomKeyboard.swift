//
//  CustomKeyboard.swift
//  Math Game
//
//  Created by Richard on 16/9/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class CustomKeyboard: UIView {
  override func accessibilityPerformEscape() -> Bool {
    AppUtil.log("escape")
    NSNotificationCenter.defaultCenter().postNotificationName("keyPressed", object: nil, userInfo:["key":String(KeyboardKey.Cancel.rawValue)])

    return true
  }

  override func accessibilityPerformMagicTap() -> Bool {
    AppUtil.log("magic")
    NSNotificationCenter.defaultCenter().postNotificationName("keyPressed", object: nil, userInfo:["key":String(KeyboardKey.Confirm.rawValue)])
    
    return true
  }
}
