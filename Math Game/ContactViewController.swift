//
//  ContactViewController.swift
//  Math Game
//
//  Created by Richard on 22/12/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    UILabel.appearance().textColor = UIColor.blackColor()
  }

  override func viewWillDisappear(animated: Bool) {
    var userDefaults = NSUserDefaults()
    var fgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor
    
    super.viewWillDisappear(animated)
    UILabel.appearance().textColor = fgColor
    UITextField.appearance().textColor = fgColor
  }

  @IBAction func backBtnClicked(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

}
