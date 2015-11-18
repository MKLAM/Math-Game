//
//  AddSubViewController.swift
//  Math Game
//
//  Created by Richard on 9/20/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit
import AudioToolbox

class NumberLabel: UILabel {
  override func accessibilityElementDidBecomeFocused() {
    var mySound: SystemSoundID = 0
    var soundURL: CFURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "do", "mp3", nil)
    switch self.tag {
    case 1, 11, 21, 31:
      soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "do", "mp3", nil)
    case 2, 12, 22:
      soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "re", "mp3", nil)
    case 3, 13, 23:
      soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "mi", "mp3", nil)
    case 24:
      soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "fa", "mp3", nil)
    default:
      break
    }
    AudioServicesCreateSystemSoundID(soundURL, &mySound)
    AudioServicesPlaySystemSound(mySound)
    
    NSNotificationCenter.defaultCenter().postNotificationName("buttonFocused", object:nil, userInfo:["tag":"\(self.tag)"])
    AppUtil.log("\(self.tag)")
  }
  
  override func accessibilityElementDidLoseFocus() {
    NSNotificationCenter.defaultCenter().postNotificationName("buttonLostFocus", object:nil, userInfo:["tag":"\(self.tag)"])
  }
}

class AddSubtractViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet var opImage: UIImageView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var advance1Switch: UISwitch!
  @IBOutlet weak var advance10Switch: UISwitch!
  @IBOutlet weak var advance100Switch: UISwitch!
  @IBOutlet weak var completeImage: UIImageView!
  @IBOutlet weak var gridImage: UIImageView!
  
  struct AnswerStruct {
    var value: Character
    var hasCarry: Bool
    var isLast: Bool
  }
  
  // Keep track of starting field tags
  let operand1StartTag = 1
  let operand2StartTag = 11
  let answerStartTag = 21
  let carryStartTag = 31
  
  var operand1 = 0
  var operand2 = 0
  var answer = 0
  var operand1Array = [" ", " ", " "]
  var operand2Array = [" ", " ", " "]
  var carryArray: [Bool] = [false, false, false]
  var answerArray = [
    AnswerStruct(value: " ", hasCarry: false, isLast: false)
  ]
  var finalAnswerString = ""

  var currOp = OpType.Add
  var currField = 0
  var currFieldText = ""
  
  var difficultyLevel = DifficultyLevel.Easy
  var holdObj = RetainObj()
  
  let longCalcParam = LongCalcParam()

  // MARK: - View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var tmpTextField: UITextField

    // Assign custom keyboard to the answer fields
    for i in (0...3) {
      tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
      tmpTextField.inputView = AppUtil.createKeyboardView(holdObj)
    }
    
    currField = answerStartTag   // start with first field
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    AppUtil.setCustomColors(view)
    view.backgroundColor = UIColor.clearColor()
    gridImage.image = gridImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
  
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, questionLabel)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyPressed", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyPressed:", name: "keyPressed", object: nil)
  }
  
  override func viewDidDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyPressed", object: nil)
  }

  // MARK: - Screen buttons
  @IBAction func carryBtnClicked(sender: AnyObject) {
    var tmpSwitch: UISwitch = view.viewWithTag(sender.tag) as! UISwitch
    
    if tmpSwitch.on {
      carryArray[sender.tag - carryStartTag] = true
    } else {
      carryArray[sender.tag - carryStartTag] = false
    }
    
    checkResult()
  }
  
  // MARK: - Main
  
  func genNewQuestion(op: OpType, level: DifficultyLevel, customOperand1: Int, customOperand2: Int) {
    AppUtil.log("Into Add/Subtract")
    difficultyLevel = level
    
    currOp = op
    
    if op == OpType.Add {
      if difficultyLevel == DifficultyLevel.Easy {
        operand1 = Int(arc4random_uniform(longCalcParam.addEasyLimit)) + 1
        operand2 = Int(arc4random_uniform(longCalcParam.addEasyLimit)) + 1
      } else if difficultyLevel == DifficultyLevel.Difficult {
        operand1 = Int(arc4random_uniform(longCalcParam.addDifficultLimit)) + 1
        operand2 = Int(arc4random_uniform(longCalcParam.addDifficultLimit)) + 1
      } else {   // custome question
        operand1 = customOperand1
        operand2 = customOperand2
      }
      answer = operand1 + operand2
    } else {
      if difficultyLevel == DifficultyLevel.Easy || difficultyLevel == DifficultyLevel.Difficult {
        do {
          if difficultyLevel == DifficultyLevel.Easy {
            operand1 = Int(arc4random_uniform(longCalcParam.subtractEasyLimit)) + 1
            operand2 = Int(arc4random_uniform(longCalcParam.subtractEasyLimit)) + 1
          } else {
            operand1 = Int(arc4random_uniform(longCalcParam.subtractDifficultLimit)) + 1
            operand2 = Int(arc4random_uniform(longCalcParam.subtractDifficultLimit)) + 1
          }
          answer = operand1 - operand2
        } while answer <= 0
      } else {   // custom question
        operand1 = customOperand1
        operand2 = customOperand2
        answer = operand1 - operand2
      }
    }
    
    println("Solve - \(operand1) - \(operand2) - \(answer)")

    // Setup the operand arrays
    var counter: Int
    var tmpString: String
    
    counter = 0
    tmpString = String(operand1)
    while count(tmpString) < 3 {
      tmpString = " " + tmpString
    }
    for c in tmpString {
      operand1Array[2 - counter] = String(c)
      counter++
    }

    tmpString = String(operand2)
    while count(tmpString) < 3 {
      tmpString = " " + tmpString
    }
    counter = 0
    for c in tmpString {
      operand2Array[2 - counter] = String(c)
      counter++
    }

    // Setup answerArray
    answerArray = [
      AnswerStruct(value: " ", hasCarry: false, isLast: false),
      AnswerStruct(value: " ", hasCarry: false, isLast: false),
      AnswerStruct(value: " ", hasCarry: false, isLast: false),
      AnswerStruct(value: " ", hasCarry: false, isLast: false),
    ]

    tmpString = String(answer)
    while count(tmpString) < 4 {
      tmpString = " " + tmpString
    }
    
    counter = 0
    for c in tmpString {
      answerArray[3 - counter].value = c
      counter++
    }
    
    answerArray[count(String(answer)) - 1].isLast = true
    
    // Setup carry
    var carryDigit = 0
    var tmp1: Int, tmp2: Int
    for i in (0...2) {
      tmp1 = operand1Array[i] == " " ? 0 : operand1Array[i].toInt()!
      tmp2 = operand2Array[i] == " " ? 0 : operand2Array[i].toInt()!

      if (currOp == .Add && (tmp1 + tmp2 + carryDigit) >= 10) ||
         (currOp == .Subtract && (tmp1 - tmp2 - carryDigit) < 0) {
        answerArray[i].hasCarry = true
        carryDigit = 1
      } else {
        carryDigit = 0
      }
      println("\(i) - Carry \(carryDigit)")
    }

    // Clear the carry array
    carryArray = [false, false, false]
    
    setupScreen()
  }
  
  func setupScreen() {
    var tmpTextField: UITextField
    var tmpLabel: UILabel
    var tmpSwitch: UISwitch
    
    // Hide the complete image
    completeImage.hidden = true
    
    // Clear the answer and carry fields
    for i in (0...3) {
      // Answer fields
      tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
      tmpTextField.text = ""
      
      //Enable the first field
      if i == 0 {
        tmpTextField.enabled = true
        tmpTextField.setFieldStyle(FieldStyle.Active)
        currField = tmpTextField.tag
      } else {
        tmpTextField.enabled = false
        tmpTextField.setFieldStyle(FieldStyle.Inactive)
        
        // Hide fields that are not needed
        if answerArray[i].value != " " {
          tmpTextField.hidden = false
        } else {
          tmpTextField.hidden = true
        }
      }

      // Carry fields
      if i != 3 {  // only have 3 switches
        tmpSwitch = view.viewWithTag(carryStartTag + i) as! UISwitch
        tmpSwitch.on = false
        tmpSwitch.enabled = i == 0 ? true : false   // only enable the first carry switch

        // Hide fields that are not needed
//        if answerArray[i].hasCarry {
//          tmpSwitch.hidden = false
//        } else {
//          tmpSwitch.hidden = true
//        }
      }
      
      // This is what you can do if want to use custom action
//      let one = UIAccessibilityCustomAction(name: "One", target: self, selector: "doOne")
//      let two = UIAccessibilityCustomAction(name: "Two", target: self, selector: "doTwo")
//      let three = UIAccessibilityCustomAction(name: "Three", target: self, selector: "doTwo")
//      tmpTextField.accessibilityCustomActions = [one, two, three]
    }
    
    // Display the operand fields
    for i in (0...2) {
      tmpLabel = view.viewWithTag(operand1StartTag + i) as! UILabel
      tmpLabel.text = String(operand1Array[i])
      if tmpLabel.text == " " {
        tmpLabel.hidden = true
      } else {
        tmpLabel.hidden = false
      }
      switch i {
      case 0:
        tmpLabel.accessibilityLabel = tmpLabel.text!
      case 1:
        tmpLabel.accessibilityLabel = tmpLabel.text! + "十"
      case 2:
        tmpLabel.accessibilityLabel = tmpLabel.text! + "百"
      default:
        break
      }

      tmpLabel = view.viewWithTag(operand2StartTag + i) as! UILabel
      tmpLabel.text = String(operand2Array[i])
      switch i {
      case 0:
        tmpLabel.accessibilityLabel = tmpLabel.text!
      case 1:
        tmpLabel.accessibilityLabel = tmpLabel.text! + "十"
      case 2:
        tmpLabel.accessibilityLabel = tmpLabel.text! + "百"
      default:
        break
      }
      // Hide fields that are not needed
      if tmpLabel.text == " " {
        tmpLabel.hidden = true
      } else {
        tmpLabel.hidden = false
      }
    }

    // Setup opImage
    if currOp == .Add {
      opImage.image = UIImage(named: "op-add")
    } else {
      opImage.image = UIImage(named: "op-subtract")
    }

    // Setup accessibility
    if currOp == .Add {
      opImage.accessibilityLabel = "加"
      questionLabel.accessibilityLabel = "\(operand1)加\(operand2)等如幾多?"
      finalAnswerString = "答對啦"
      finalAnswerString = finalAnswerString + "\(operand1)加\(operand2)等如" + String(answer)
      advance1Switch.accessibilityLabel = "個位進位"
      advance10Switch.accessibilityLabel = "十位進位"
      advance100Switch.accessibilityLabel = "百位進位"
    } else {
      opImage.accessibilityLabel = "減"
      questionLabel.accessibilityLabel = "\(operand1)減\(operand2)等如幾多?"
      finalAnswerString = "答對啦"
      finalAnswerString = finalAnswerString + "\(operand1)減\(operand2)等如" + String(answer)
      advance1Switch.accessibilityLabel = "個位借位"
      advance10Switch.accessibilityLabel = "十位借位"
      advance100Switch.accessibilityLabel = "百位借位"
    }
    opImage.accessibilityTraits = UIAccessibilityTraitNone   // so it will not speak "image"
  }
  
  func checkResult() {
    var index = currField - answerStartTag
    var tmpTextField = self.view.viewWithTag(currField) as! UITextField

    // If attempted at text field but failed, then need to retry
    if tmpTextField.text != "" && tmpTextField.text != String(answerArray[index].value) {
      tmpTextField.text = ""
      tmpTextField.becomeFirstResponder()
      AppUtil.playEffect(SoundEffect.AnswerIncorrect)
      return
    }
    
    if index < 3 {
      var tmpSwitch = self.view.viewWithTag(carryStartTag + index) as! UISwitch

      // Check digit and carry
      if tmpTextField.text == String(answerArray[index].value) {
        if (carryArray[index] == answerArray[index].hasCarry) {   // both digit and carry ok
          tmpTextField.enabled = false
          tmpTextField.setFieldStyle(FieldStyle.Inactive)
          tmpSwitch.enabled = false
          
          if answerArray[index].isLast {
            AppUtil.log("Complete la")
            AppUtil.playEffect(SoundEffect.AnswerCorrect)
            AppUtil.sayIt(finalAnswerString, withDelay: 3.0)
            completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            completeImage.hidden = false
            NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
          } else {
            // Enable next set of field and carry
            // A necessary step to check in case carryBtnClicked and textEndEditing are called together
            if (self.view.viewWithTag(currField) as! UITextField).text != "" {
              currField++
              tmpTextField = self.view.viewWithTag(currField) as! UITextField
              tmpTextField.enabled = true
              tmpTextField.setFieldStyle(FieldStyle.Active)
              tmpTextField.becomeFirstResponder()
              currField = tmpTextField.tag
            }
            
            if index == 2 {   // moving to the very last answer field, no more carry
              tmpSwitch.enabled = false
            } else {
              tmpSwitch = self.view.viewWithTag(carryStartTag + index + 1) as! UISwitch
              tmpSwitch.enabled = true
            }
          }
        } else {   // digit ok but carry not ok
          // Seems cannot make UISwitch first responder, so stay with current field
          UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, tmpTextField)
          NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
        }
      }
    } else {  // at the very last position of answer
      // Check digit only
      if tmpTextField.text == String(answerArray[index].value) {
        tmpTextField.enabled = false
        tmpTextField.setFieldStyle(FieldStyle.Inactive)
        
        if answerArray[index].isLast {
          AppUtil.log("Complete la")
          AppUtil.playEffect(SoundEffect.AnswerCorrect)
          AppUtil.sayIt(finalAnswerString, withDelay: 3.0)
          completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
          completeImage.hidden = false
          NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
        } else {
          currField++
          tmpTextField = self.view.viewWithTag(currField) as! UITextField
          tmpTextField.enabled = true
          tmpTextField.setFieldStyle(FieldStyle.Active)
          tmpTextField.becomeFirstResponder()
          currField = tmpTextField.tag
        }
      }
    }
  }
  
  func redoBtnClicked() {
    carryArray = [false, false, false]
    currField = answerStartTag
    setupScreen()
  }

  // MARK: - Gestures

  /*
  override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
    var tmpTextField = self.view.viewWithTag(currField) as! UITextField
    
    switch direction {
    case .Right, .Left:
        checkResult()
    case .Down:
      if var fieldValue = tmpTextField.text.toInt() {
        fieldValue = ++fieldValue > 9 ? 0 : fieldValue
        tmpTextField.text = String(fieldValue)
      } else {
        tmpTextField.text = "0"
      }
      AppUtil.sayIt(tmpTextField.text)
    case .Up:
      if var fieldValue = tmpTextField.text.toInt() {
        fieldValue = --fieldValue < 0 ? 9 : fieldValue
        tmpTextField.text = String(fieldValue)
      } else {
        tmpTextField.text = "0"
      }
      AppUtil.sayIt(tmpTextField.text)
    default:
      break
    }
    
    // Testing pitch change for Answer fields
    if currField >= answerStartTag {
      var tmpMutableString = NSMutableAttributedString()
      var pitchValue = (Float)(currField - answerStartTag) * 0.6
      tmpMutableString = NSMutableAttributedString(string: tmpTextField.text, attributes: [UIAccessibilitySpeechAttributePitch:pitchValue])
      tmpTextField.attributedText = tmpMutableString
    }

    return true
  }
  */

  // MARK: - Text editing
  
  func textFieldDidBeginEditing(textField: UITextField) {
    currField = textField.tag
    
    // Store value in case the user cancel
    currFieldText = textField.text
    textField.text = ""
    
    AppUtil.sayIt(Voices.keyboardIsShown)
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, textField.inputView?.viewWithTag(5))
    
    // Keep the user in the keyboard view
//    view.accessibilityElementsHidden = true
    NSNotificationCenter.defaultCenter().postNotificationName("beginEditing", object:nil, userInfo:nil)
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    checkResult()
    
    AppUtil.sayIt(Voices.keyboardIsHidden)
//    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, textField)
  }

  func keyPressed(notification: NSNotification) {
    let userInfo: Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
    let key = userInfo["key"]
    var keyReceived: KeyboardKey = KeyboardKey(rawValue: key!.toInt()!)!

    // Get a reference to the current field
    var tmpTextField = UITextField()
    tmpTextField = self.view.viewWithTag(currField) as! UITextField
    
    switch keyReceived {
    case .Zero, .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine:
      // Append only if field is empty
      if count(tmpTextField.text) == 0 {
        tmpTextField.text = tmpTextField.text + String(keyReceived.rawValue)
        tmpTextField.resignFirstResponder()
        // Testing pitch change for Answer fields
//        if currField >= answerStartTag {
//          var tmpMutableString = NSMutableAttributedString()
//          var pitchValue = (Float)(currField - answerStartTag) * 0.6
//          tmpMutableString = NSMutableAttributedString(string: tmpTextField.text, attributes: [UIAccessibilitySpeechAttributePitch:pitchValue])
//          tmpTextField.attributedText = tmpMutableString
//        }
        AppUtil.sayIt(tmpTextField.text)
      } else {
        AppUtil.sayIt(Voices.fieldIsFull)
      }
    case .Delete:
      tmpTextField.text = ""
    case .Cancel:
      tmpTextField.text = currFieldText
      tmpTextField.resignFirstResponder()
//      view.accessibilityElementsHidden = false
      NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
    case .Confirm:
      tmpTextField.resignFirstResponder()
//      view.accessibilityElementsHidden = false
      NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
    default:
      break
    }
  }
}
