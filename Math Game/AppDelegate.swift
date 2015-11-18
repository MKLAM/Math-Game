//
//  AppDelegate.swift
//  Math Game
//
//  Created by Richard on 16/9/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Create user defaults if they do not already exist
    var userDefaults = NSUserDefaults()
    
    if let tmpValue = userDefaults.objectForKey("fractionAdd") as? Bool {
      AppUtil.log("Defaults have been set")
      
      // If defaults have been set, need to adopt the colors immediately
      CustomUIView.appearance().backgroundColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("bgColor") as! NSData) as? UIColor
      UILabel.appearance().textColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor
      UITextField.appearance().textColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor
      UIButton.appearance().backgroundColor = UIColor.clearColor()
      UIButton.appearance().setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
      UIButton.appearance().setBackgroundImage(UIImage(named: "btnBackground2"), forState: UIControlState.Normal)
    } else {
      userDefaults.setValue(true, forKey: "fractionAdd")
      userDefaults.setValue(true, forKey: "fractionSubtract")
      userDefaults.setValue(true, forKey: "fractionMultiply")
      userDefaults.setValue(true, forKey: "fractionDivide")
      userDefaults.setValue(true, forKey: "longCalcAdd")
      userDefaults.setValue(true, forKey: "longCalcSubtract")
      userDefaults.setValue(true, forKey: "longCalcMultiply")
      userDefaults.setValue(true, forKey: "longCalcDivide")
      userDefaults.setValue(1, forKey: "rulerOrientation")   // horizontal
      
      // Default foreground, background and active colors
      var colorData = NSKeyedArchiver.archivedDataWithRootObject(UIColor.whiteColor())
      userDefaults.setValue(colorData, forKey: "bgColor")
      colorData = NSKeyedArchiver.archivedDataWithRootObject(UIColor.blackColor())
      userDefaults.setValue(colorData, forKey: "fgColor")
      colorData = NSKeyedArchiver.archivedDataWithRootObject(UIColor.redColor())
      userDefaults.setValue(colorData, forKey: "activeColor")

      CustomUIView.appearance().backgroundColor = UIColor.whiteColor()
      UILabel.appearance().textColor = UIColor.blackColor()
      UITextField.appearance().textColor = UIColor.blackColor()
      UIButton.appearance().backgroundColor = UIColor.clearColor()
      UIButton.appearance().setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
      UIButton.appearance().setBackgroundImage(UIImage(named: "btnBackground2"), forState: UIControlState.Normal)
      
      // Default for grid display
      userDefaults.setValue(false, forKey: "displayGrid")
    }
    
    // Copy the default plists to local if not yet done
    
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0) as! NSString
    let fileManager = NSFileManager.defaultManager()
    
    var filePath = documentsDirectory.stringByAppendingPathComponent("FractionQuestions.plist")
    if(!fileManager.fileExistsAtPath(filePath)) {
      let bundle = NSBundle.mainBundle().pathForResource("FractionQuestions", ofType: "plist")
      fileManager.copyItemAtPath(bundle!, toPath: filePath, error:nil)
    }
    
    filePath = documentsDirectory.stringByAppendingPathComponent("LongCalcQuestions.plist")
    if(!fileManager.fileExistsAtPath(filePath)) {
      let bundle = NSBundle.mainBundle().pathForResource("LongCalcQuestions", ofType: "plist")
      fileManager.copyItemAtPath(bundle!, toPath: filePath, error:nil)
    }

    filePath = documentsDirectory.stringByAppendingPathComponent("RulerQuestions.plist")
    if(!fileManager.fileExistsAtPath(filePath)) {
      let bundle = NSBundle.mainBundle().pathForResource("RulerQuestions", ofType: "plist")
      fileManager.copyItemAtPath(bundle!, toPath: filePath, error:nil)
    }
    
    filePath = documentsDirectory.stringByAppendingPathComponent("AlgebraQuestions.plist")
    if(!fileManager.fileExistsAtPath(filePath)) {
      let bundle = NSBundle.mainBundle().pathForResource("AlgebraQuestions", ofType: "plist")
      fileManager.copyItemAtPath(bundle!, toPath: filePath, error:nil)
    }

//    window?.backgroundColor = UIColor.yellowColor()
//    CustomUIView.appearance().backgroundColor = UIColor.yellowColor()
//    UILabel.appearance().textColor = UIColor.redColor()
    
    return true
  }
  
  func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
    NSNotificationCenter.defaultCenter().postNotificationName("importRequested", object:nil, userInfo:["url":url])
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as! an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as! part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

