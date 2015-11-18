//
//  AppUtil.swift
//  Math Game
//
//  Created by Richard on 18/9/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import AVFoundation

enum OpType {
  case Add
  case Subtract
  case Multiply
  case Divide
}

enum FieldStyle {
  case Active
  case Inactive
}

enum DifficultyLevel {
  case Easy
  case Difficult
  case Custom
}

enum SolveMethod {
  case Balance
  case Direct
}

enum RulerType {
  case Direct
  case Compare
}

enum RulerOrientation {
  case Horizontal
  case Vertical
}

enum KeyboardKey: Int {
  case Zero=0
  case One
  case Two
  case Three
  case Four
  case Five
  case Six
  case Seven
  case Eight
  case Nine
  case Confirm=21
  case Cancel
  case Delete
  case X=31
  case Add=41
  case Subtract
  case Divide
  case Sign
}

enum SoundEffect {
  case AnswerCorrect
  case AnswerIncorrect
}

//extension UIButton {
//  override public func accessibilityElementDidBecomeFocused() {
//    NSNotificationCenter.defaultCenter().postNotificationName("buttonInFocus", object:nil, userInfo:["tag":"\(self.tag)"])
//  }
//}

extension UITextField {
  func setFieldStyle(fieldStyle: FieldStyle) {
    let userDefaults = NSUserDefaults()
    var activeColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("activeColor") as! NSData) as? UIColor
    if fieldStyle == FieldStyle.Active {
      self.layer.borderColor = activeColor?.CGColor
      self.layer.borderWidth = 5
    } else {
      self.layer.borderColor = UIColor.blackColor().CGColor
      self.layer.borderWidth = 1
    }
  }
}

class AppUtil: NSObject {
  
  class func log(logString: String) {
    println(logString)
  }
  
  class func setCustomColors(view: UIView) {
    var userDefaults = NSUserDefaults()
    var fgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor
    
    for sv in view.subviews {
      if sv.isKindOfClass(UIImageView)  {
        var tmpImage = sv as! UIImageView
        tmpImage.image = tmpImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        tmpImage.tintColor = fgColor
      } else if sv.isKindOfClass(UIButton) {
        var tmpButton: UIButton = sv as! UIButton
        tmpButton.backgroundColor = UIColor.clearColor()
        tmpButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        tmpButton.setBackgroundImage(UIImage(named: "btnBackground2"), forState: UIControlState.Normal)
      }
    }
  }
  
  class func sayIt(message: String, withDelay delay: Double = 0.1) {
    // Need to create an object for the timer to hold on to to invoke the selector
    var holdObj = RetainObj()
    var timer = NSTimer.scheduledTimerWithTimeInterval(delay, target: holdObj, selector: "timeToSay:", userInfo: message, repeats: false)
  }

  class func delayedSayIt(message: String, delay: Double) {
    // Need to create an object for the timer to hold on to to invoke the selector
    var holdObj = RetainObj()
    var timer = NSTimer.scheduledTimerWithTimeInterval(delay, target: holdObj, selector: "timeToSay:", userInfo: message, repeats: false)
  }

  class func TTS(message: String) {
    var speechSyn = AVSpeechSynthesizer()
    var speechUtterance = AVSpeechUtterance(string: message)
    speechSyn.speakUtterance(speechUtterance)
  }
  
  class func createKeyboardView(holdObj: RetainObj, withOp: Bool = false, withX: Bool = false ) -> UIView {
    var userDefaults = NSUserDefaults()
    var bgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("bgColor") as! NSData) as? UIColor

    var subviewArray =  NSBundle.mainBundle().loadNibNamed("CustomKeyboard", owner: self, options: nil)
    var mainView = subviewArray[0] as! UIView
    
    mainView.frame = CGRectMake(0.0, 0.0, 768.0, 150.0)
    mainView.backgroundColor = bgColor  // set keyboard color to be the same as! the main view
    
    // This is needed to prevent resizing to default keyboard size
    mainView.autoresizingMask = UIViewAutoresizing.None
    
    // Set target for each buttons in the input view
    for sv in mainView.subviews {
      if sv.isKindOfClass(UIButton)  {
        sv.addTarget(holdObj, action:"customKeyboardBtnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
      }
      
      if sv.tag >= 41 && sv.tag <= 44 {   // +-/ and sign buttons
        if withOp {
          (sv as! UIView).hidden = false
          (sv as! UIView).isAccessibilityElement = true
        } else {
          (sv as! UIView).hidden = true
          (sv as! UIView).isAccessibilityElement = false
        }
      }
      
      if sv.tag == 31 {   // x
        if withX {
          (sv as! UIView).hidden = false
          (sv as! UIView).isAccessibilityElement = true
        } else {
          (sv as! UIView).hidden = true
          (sv as! UIView).isAccessibilityElement = false
        }
      }
      
      if sv.tag == 999 {   // the divider line
        var tmpImage = sv as! UIImageView
        tmpImage.image = tmpImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        switch bgColor! as UIColor {
        case UIColor.blackColor():
          tmpImage.tintColor = UIColor.whiteColor()
        case UIColor.whiteColor():
          tmpImage.tintColor = UIColor.blackColor()
        case UIColor.yellowColor():
          tmpImage.tintColor = UIColor.blackColor()
        case UIColor.blueColor():
          tmpImage.tintColor = UIColor.whiteColor()
        case UIColor.redColor():
          tmpImage.tintColor = UIColor.whiteColor()
        case UIColor.greenColor():
          tmpImage.tintColor = UIColor.whiteColor()
        default:
          tmpImage.tintColor = UIColor.blackColor()
        }
      }
    }
    return mainView
  }

  class func playEffect(effect: SoundEffect) {
    var effectSound: SystemSoundID = 0
    var soundURL: CFURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "do", "mp3", nil)   // default sound
    
    log("Playing effect")
    switch effect {
    case .AnswerCorrect:
      soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "hooray", "mp3", nil)
      sayIt(Voices.answerCorrect)
    case .AnswerIncorrect:
      soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "wrong", "mp3", nil)
    }

    AudioServicesCreateSystemSoundID(soundURL, &effectSound)
    AudioServicesPlaySystemSound(effectSound)
  }
  
  class func toVOText(operand1: String, operator1: OpType?, operand2: String, hasEqual: Bool?, operand3: String, operator2: OpType?, operand4: String) -> String {
    var output = ""
    
    output = operand1
    
    if operand1 != "" && operator1 != nil {
      switch operator1! {
      case .Add:
        output += "加"
      case .Subtract:
        output += "減"
      case .Multiply:
        output += "乘"
      case .Divide:
        output += "除"
      }
    }
    
    output += operand2
    
    if hasEqual != nil {
      if hasEqual! {
        output += "等如"
      }
    }
    
    output += operand3
    
    if operand3 != "" && operator2 != nil {
      switch operator2! {
      case .Add:
        output += "加"
      case .Subtract:
        output += "減"
      case .Multiply:
        output += "乘"
      case .Divide:
        output += "除"
      }
    }
    
    output += operand4
    
    return output
  }
}

// A class for keyboard callback
class RetainObj: NSObject {
  func timeToSay(timer: NSTimer) {
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, timer.userInfo as! String)
  }

  func customKeyboardBtnClicked(sender: UIButton!) {
    var keyPressed: KeyboardKey
    
    // Tag 0..9 = 0..9, 21 = confirm, 22 = cancel
    switch sender!.tag {
    case 0...9:
      keyPressed = KeyboardKey(rawValue: sender!.tag)!
    case 21:
      keyPressed = .Confirm
    case 22:
      keyPressed = .Cancel
    case 23:
      keyPressed = .Delete
    case 31:
      keyPressed = .X
    case 41:
      keyPressed = .Add
    case 42:
      keyPressed = .Subtract
    case 43:
      keyPressed = .Divide
    case 44:
      keyPressed = .Sign
    default:
      keyPressed = .Cancel
    }
    NSNotificationCenter.defaultCenter().postNotificationName("keyPressed", object:nil, userInfo:["key":String(keyPressed.rawValue)])
  }
}

// This class is created so that the we can use UIAppearance to set the background color
// If we use UIAppearance on UIView, all other subclasses of UIView such as! UIButton, etc will be affected
class CustomUIView: UIView {
  
}
