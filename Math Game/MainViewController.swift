//
//  ViewController.swift
//  Math Game
//
//  Created by Richard on 16/9/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  @IBOutlet weak var fractionEasyBtn: UIButton!
  @IBOutlet weak var fractionDifficultBtn: UIButton!
  @IBOutlet weak var fractionCustomBtn: UIButton!
  @IBOutlet weak var fractionSettingsBtn: UIButton!
  @IBOutlet weak var fractionHelpBtn: UIButton!
  @IBOutlet weak var longCalcEasyBtn: UIButton!
  @IBOutlet weak var longCalcDifficultBtn: UIButton!
  @IBOutlet weak var longCalcCustomBtn: UIButton!
  @IBOutlet weak var longCalcSettingsBtn: UIButton!
  @IBOutlet weak var longCalcHelpBtn: UIButton!
  @IBOutlet weak var rulerEasyBtn: UIButton!
  @IBOutlet weak var rulerDifficultBtn: UIButton!
  @IBOutlet weak var rulerCustomBtn: UIButton!
  @IBOutlet weak var rulerSettingsBtn: UIButton!
  @IBOutlet weak var rulerHelpBtn: UIButton!
  @IBOutlet weak var algebraEasyBtn: UIButton!
  @IBOutlet weak var algebraDifficultBtn: UIButton!
  @IBOutlet weak var algebraCustomBtn: UIButton!
  @IBOutlet weak var algebraSettingsBtn: UIButton!
  @IBOutlet weak var algebraHelpBtn: UIButton!
  
  @IBOutlet weak var appSettingsBtn: UIButton!
  @IBOutlet weak var contactUsBtn: UIButton!
  var questionsBank = []
  var importURL = NSURL()
  
  // Mark: - View
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Set VO sequence
    view.accessibilityElements = [fractionEasyBtn, fractionDifficultBtn, fractionCustomBtn, fractionSettingsBtn, fractionHelpBtn, longCalcEasyBtn, longCalcDifficultBtn, longCalcCustomBtn, longCalcSettingsBtn, longCalcHelpBtn, rulerEasyBtn, rulerDifficultBtn, rulerCustomBtn, rulerSettingsBtn, rulerHelpBtn, algebraEasyBtn, algebraDifficultBtn, algebraCustomBtn, algebraSettingsBtn, algebraHelpBtn, appSettingsBtn, contactUsBtn]

    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0) as! NSString
    var filePath = documentsDirectory.stringByAppendingPathComponent("FractionQuestions.plist")
    
    questionsBank = NSArray(contentsOfFile: filePath)!
    QuestionCount.fraction = questionsBank.count
    
    filePath = documentsDirectory.stringByAppendingPathComponent("LongCalcQuestions.plist")
    questionsBank = NSArray(contentsOfFile: filePath)!
    QuestionCount.longCalc = questionsBank.count
    
    filePath = documentsDirectory.stringByAppendingPathComponent("RulerQuestions.plist")
    questionsBank = NSArray(contentsOfFile: filePath)!
    QuestionCount.ruler = questionsBank.count
    
    filePath = documentsDirectory.stringByAppendingPathComponent("AlgebraQuestions.plist")
    questionsBank = NSArray(contentsOfFile: filePath)!
    QuestionCount.algebra = questionsBank.count
    
    // Set color
  }
  
  override func viewDidAppear(animated: Bool) {
//    UIApplication.sharedApplication().keyWindow?.tintColor = UIColor.redColor()
    
    // Enable custom question button only when there are custom questions
    // Need to do it here as! viewDidLoad will only be called once
    fractionCustomBtn.enabled = QuestionCount.fraction == 0 ? false : true
    longCalcCustomBtn.enabled = QuestionCount.longCalc == 0 ? false : true
    rulerCustomBtn.enabled = QuestionCount.ruler == 0 ? false : true
    algebraCustomBtn.enabled = QuestionCount.algebra == 0 ? false : true
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleImport:", name: "importRequested", object: nil)
    
    AppUtil.setCustomColors(view)
  }
  
  override func viewDidDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "importRequested", object: nil)
  }
  
//  override func shouldAutorotate() -> Bool {
//    return true
//  }
//  
//  override func supportedInterfaceOrientations() -> Int {
//    return Int(UIInterfaceOrientationMask.Landscape.rawValue)
//  }
  
  // Mark: - Main
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let segueID:String = segue.identifier!
    
    switch segueID {
    case "fractionEasy":
      let vc = segue.destinationViewController as! FractionViewController
      vc.setDifficultyLevel(DifficultyLevel.Easy)
    case "fractionDifficult":
      let vc = segue.destinationViewController as! FractionViewController
      vc.setDifficultyLevel(DifficultyLevel.Difficult)
    case "fractionCustom":
      let vc = segue.destinationViewController as! FractionViewController
      vc.setDifficultyLevel(DifficultyLevel.Custom)
    case "fractionSettings":
      let vc = segue.destinationViewController as! SettingsViewController
      vc.initGameType("fraction")
    case "longCalcEasy":
      let vc = segue.destinationViewController as! LongCalcViewController
      vc.setDifficultyLevel(DifficultyLevel.Easy)
    case "longCalcDifficult":
      let vc = segue.destinationViewController as! LongCalcViewController
      vc.setDifficultyLevel(DifficultyLevel.Difficult)
    case "longCalcCustom":
      let vc = segue.destinationViewController as! LongCalcViewController
      vc.setDifficultyLevel(DifficultyLevel.Custom)
    case "longCalcSettings":
      let vc = segue.destinationViewController as! SettingsViewController
      vc.initGameType("longCalc")
    case "rulerEasy":
      let vc = segue.destinationViewController as! RulerViewController
      vc.setDifficultyLevel(DifficultyLevel.Easy)
    case "rulerDifficult":
      let vc = segue.destinationViewController as! RulerViewController
      vc.setDifficultyLevel(DifficultyLevel.Difficult)
    case "rulerCustom":
      let vc = segue.destinationViewController as! RulerViewController
      vc.setDifficultyLevel(DifficultyLevel.Custom)
    case "rulerSettings":
      let vc = segue.destinationViewController as! SettingsViewController
      vc.initGameType("ruler")
    case "algebraEasy":
      let vc = segue.destinationViewController as! AlgebraViewController
      vc.setDifficultyLevel(DifficultyLevel.Easy)
    case "algebraDifficult":
      let vc = segue.destinationViewController as! AlgebraViewController
      vc.setDifficultyLevel(DifficultyLevel.Difficult)
    case "algebraCustom":
      let vc = segue.destinationViewController as! AlgebraViewController
      vc.setDifficultyLevel(DifficultyLevel.Custom)
    case "algebraSettings":
      let vc = segue.destinationViewController as! SettingsViewController
      vc.initGameType("algebra")
    case "fractionHelp":
      let vc = segue.destinationViewController as! HelpViewController
      vc.initGameType("fraction")
    case "longCalcHelp":
      let vc = segue.destinationViewController as! HelpViewController
      vc.initGameType("longCalc")
    case "rulerHelp":
      let vc = segue.destinationViewController as! HelpViewController
      vc.initGameType("ruler")
    case "algebraHelp":
      let vc = segue.destinationViewController as! HelpViewController
      vc.initGameType("algebra")
    default:
      break
    }
  }
  
  func handleImport(notification: NSNotification) {
    let userInfo: Dictionary<String,NSURL> = notification.userInfo as! Dictionary<String,NSURL>
    importURL = userInfo["url"]! as NSURL
    
    var alert = UIAlertController(title: "注意", message: "滙入題目嗎?", preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) in
      let urlString = self.importURL.absoluteString
      var filePath = ""
      let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
      let documentsDirectory = paths.objectAtIndex(0)as! NSString
      
      AppUtil.log("Ready to handle \(urlString)")
      
      if urlString?.rangeOfString("fraction") != nil {
        filePath = documentsDirectory.stringByAppendingPathComponent("FractionQuestions.plist")
      } else if urlString?.rangeOfString("longCalc") != nil {
        filePath = documentsDirectory.stringByAppendingPathComponent("LongCalcQuestions.plist")
      } else if urlString?.rangeOfString("ruler") != nil {
        filePath = documentsDirectory.stringByAppendingPathComponent("RulerQuestions.plist")
      } else if urlString?.rangeOfString("algebra") != nil {
        filePath = documentsDirectory.stringByAppendingPathComponent("AlgebraQuestions.plist")
      }
      
      if filePath != "" {
        let importData = NSData(contentsOfURL: self.importURL)
        importData!.writeToFile(filePath, atomically: false)

        // Refresh the custom question button status
        self.viewDidLoad()
        self.viewDidAppear(true)
      }
    }))
    alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Default, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
}

