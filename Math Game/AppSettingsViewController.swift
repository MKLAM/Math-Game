//
//  AppSettingsViewController.swift
//  Math Game
//
//  Created by Richard on 10/11/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class AppSettingsViewController: UIViewController {
  @IBOutlet weak var bgColorView: UIView!
  @IBOutlet weak var fgColorView: UIView!
  @IBOutlet weak var fgLabel: UILabel!
  @IBOutlet weak var gridSwitch: UISwitch!
  
  // MARK: - View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var userDefaults = NSUserDefaults()
    
    var bgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("bgColor") as! NSData) as? UIColor
    bgColorView.backgroundColor = bgColor
    switch bgColor! as UIColor {
    case UIColor.blackColor():
      fgLabel.text = "1"
      fgLabel.accessibilityLabel = "耳選黑底白字"
    case UIColor.whiteColor():
      fgLabel.text = "2"
      fgLabel.accessibilityLabel = "耳選白底黑字"
    case UIColor.yellowColor():
      fgLabel.text = "3"
      fgLabel.accessibilityLabel = "耳選黃底籃字"
    case UIColor.blueColor():
      fgLabel.text = "4"
      fgLabel.accessibilityLabel = "耳選籃底黃字"
    case UIColor.redColor():
      fgLabel.text = "5"
      fgLabel.accessibilityLabel = "耳選紅底白字"
    case UIColor.greenColor():
      fgLabel.text = "6"
      fgLabel.accessibilityLabel = "耳選綠底黑字"
    default:
      fgLabel.text = "0"
    }
    
    
    fgColorView.backgroundColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor
    
    gridSwitch.on = userDefaults.objectForKey("displayGrid") as! Bool
  }
  
  // This is needed to override the default button label color
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    var userDefaults = NSUserDefaults()
    var fgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor

    var tmpBtn = view.viewWithTag(1) as! UIButton    
    tmpBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    tmpBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
    tmpBtn.backgroundColor = UIColor.blackColor()
    
    tmpBtn = view.viewWithTag(2) as! UIButton
    tmpBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    tmpBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
    tmpBtn.backgroundColor = UIColor.whiteColor()

    tmpBtn = view.viewWithTag(3) as! UIButton
    tmpBtn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
    tmpBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
    tmpBtn.backgroundColor = UIColor.yellowColor()

    tmpBtn = view.viewWithTag(4) as! UIButton
    tmpBtn.setTitleColor(UIColor.yellowColor(), forState: UIControlState.Normal)
    tmpBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
    tmpBtn.backgroundColor = UIColor.blueColor()
    
    tmpBtn = view.viewWithTag(5) as! UIButton
    tmpBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    tmpBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
    tmpBtn.backgroundColor = UIColor.redColor()
    
    tmpBtn = view.viewWithTag(6) as! UIButton
    tmpBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    tmpBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
    tmpBtn.backgroundColor = UIColor.greenColor()
    
    UILabel.appearance().textColor = UIColor.blackColor()
    UITextField.appearance().textColor = UIColor.blackColor()
    
    fgLabel.textColor = fgColor
  }
  
  override func viewWillDisappear(animated: Bool) {
    var userDefaults = NSUserDefaults()
    var fgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor
    
    super.viewWillDisappear(animated)
    UILabel.appearance().textColor = fgColor
    UITextField.appearance().textColor = fgColor
  }
  
  // MARK: - Screen buttons
  
  @IBAction func backBtnClicked(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func colorBtnClicked(sender: AnyObject) {
    var userDefaults = NSUserDefaults()
    var tmpButton = sender as! UIButton
    var fgColor = UIColor.whiteColor()
    var activeColor = UIColor.redColor()
    
    bgColorView.backgroundColor = tmpButton.backgroundColor
    var colorData = NSKeyedArchiver.archivedDataWithRootObject(tmpButton.backgroundColor!)
    userDefaults.setValue(colorData, forKey: "bgColor")
    CustomUIView.appearance().backgroundColor = tmpButton.backgroundColor

    fgLabel.text = String(sender.tag)
    switch sender.tag {
    case 1:
      fgColor = UIColor.whiteColor()
      fgLabel.accessibilityLabel = "耳選黑底白字"
      activeColor = UIColor.yellowColor()
    case 2:
      fgColor = UIColor.blackColor()
      fgLabel.accessibilityLabel = "耳選白底黑字"
      activeColor = UIColor.redColor()
    case 3:
      fgColor = UIColor.blueColor()
      fgLabel.accessibilityLabel = "耳選黃底籃字"
      activeColor = UIColor.redColor()
    case 4:
      fgColor = UIColor.yellowColor()
      fgLabel.accessibilityLabel = "耳選籃底黃字"
      activeColor = UIColor.whiteColor()
    case 5:
      fgColor = UIColor.whiteColor()
      fgLabel.accessibilityLabel = "耳選紅底白字"
      activeColor = UIColor.yellowColor()
    case 6:
      fgColor = UIColor.blackColor()
      fgLabel.accessibilityLabel = "耳選綠底黑字"
      activeColor = UIColor.whiteColor()
    default:
      break
    }
    
    colorData = NSKeyedArchiver.archivedDataWithRootObject(fgColor)
    fgLabel.textColor = fgColor
    userDefaults.setValue(colorData, forKey: "fgColor")
    UILabel.appearance().textColor = fgColor
    UITextField.appearance().textColor = fgColor
    
    colorData = NSKeyedArchiver.archivedDataWithRootObject(activeColor)
    userDefaults.setValue(colorData, forKey: "activeColor")
  }
  
  @IBAction func gridSwitchClicked(sender: AnyObject) {
    var userDefaults = NSUserDefaults()
    var tmpSwitch = sender as! UISwitch
    
    if tmpSwitch.on {
      userDefaults.setValue(true, forKey: "displayGrid")
    } else {
      userDefaults.setValue(false, forKey: "displayGrid")
    }

  }
}
