//
//  MultiplyViewController.swift
//  Math Game
//
//  Created by Richard on 9/20/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class MultiplyViewController: UIViewController, UITextFieldDelegate {
  // Keep track of starting field tags
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var dividerView: UIView!
  @IBOutlet weak var completeImage: UIImageView!
  @IBOutlet weak var gridImage: UIImageView!
  
  let operand1StartTag = 1
  let operand2StartTag = 11
  let inter1StartTag = 21
  let inter2StartTag = 31
  let answerStartTag = 41
  
  var operand1 = 0
  var operand2 = 0
  var answer = 0
  var operand1Array = [" ", " ", " "]
  var operand2Array = [" ", " ", " "]
  var inter1Array = [" ", " ", " ", " ", " "]
  var inter2Array = [" ", " ", " ", " ", " "]
  var answerArray = [" ", " ", " ", " ", " ", " "]
  
  var currField = 0
  var currFieldText = ""
  var inter1LastPos = 0
  var inter2LastPos = 0
  var answerLastPos = 0
  
  var currRow = 1   // first intermediate result
  var currPos = 1   // first digit
  var orgRow = 0
  var orgPos = 0
  
  var isCancelInput = false
  
  var finalAnswerStr = ""
  
  var difficultyLevel = DifficultyLevel.Easy
  var holdObj = RetainObj()
  
  let longCalcParam = LongCalcParam()
  
  // MARK: - View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var tmpTextField: UITextField
    
    // Assign custom keyboard to the intermediate answer fields
    for i in (0...4) {
      tmpTextField = view.viewWithTag(inter1StartTag + i) as! UITextField
      tmpTextField.inputView = AppUtil.createKeyboardView(holdObj)
      tmpTextField = view.viewWithTag(inter2StartTag + i) as! UITextField
      tmpTextField.inputView = AppUtil.createKeyboardView(holdObj)
    }

    // Assign custom keyboard to the answer fields
    for i in (0...5) {
      tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
      tmpTextField.inputView = AppUtil.createKeyboardView(holdObj)
    }
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
  
  // MARK: - Main
  
  func genNewQuestion(level: DifficultyLevel, customOperand1: Int, customOperand2: Int) {
    AppUtil.log("Into Multiply")
    difficultyLevel = level
    
    currRow = 0
    currPos = 0
    
    if difficultyLevel == DifficultyLevel.Easy {
      operand1 = Int(arc4random_uniform(longCalcParam.multiplyOp1Easy)) + 1
      operand2 = Int(arc4random_uniform(longCalcParam.multiplyOp2Easy)) + 1
    } else if difficultyLevel == DifficultyLevel.Difficult {
      operand1 = Int(arc4random_uniform(longCalcParam.multiplyOp1Difficult)) + 1
      operand2 = Int(arc4random_uniform(longCalcParam.multiplyOp2Difficult)) + 1
    } else {   // custom question
      operand1 = customOperand1
      operand2 = customOperand2
    }
    answer = operand1 * operand2
    
    // Setup the operand arrays
    var counter = 0
    var tmpString: String
    
    tmpString = String(operand1)
    while count(tmpString) < 3 {
      tmpString = " " + tmpString
    }
    
    counter = 0
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
    
    // Setup the intermediate arrays
    inter1Array = [" ", " ", " ", " ", " "]
    inter2Array = [" ", " ", " ", " ", " "]

    if operand2 >= 10 {   // if operand2 < 10 there is no intermediate results, go straight to answer
      tmpString = String(operand1 * (operand2/10) * 10)
      inter1LastPos = count(tmpString)
      
      while count(tmpString) < 5 {
        tmpString = " " + tmpString
      }
      
      counter = 0
      for c in tmpString {
        inter1Array[4 - counter] = String(c)
        counter++
      }
    
      tmpString = String(operand1 * (operand2%10))
      inter2LastPos = count(tmpString)
      
      while count(tmpString) < 5 {
        tmpString = " " + tmpString
      }
      
      counter = 0
      for c in tmpString {
        inter2Array[4 - counter] = String(c)
        counter++
      }
      
      currRow = 1
      currPos = 2
    } else {
      currRow = 3   // straight to answer
      currPos = 1
    }

    // Store this in case need to redo question
    orgRow = currRow
    orgPos = currPos
    
    // Setup answerArray
    answerArray = ["", "", "", "", "", ""]
    
    tmpString = String(answer)
    answerLastPos = count(tmpString)
    
    while count(tmpString) < 6 {
      tmpString = " " + tmpString
    }
    
    counter = 0
    for c in tmpString {
      answerArray[5 - counter] = String(c)
      counter++
    }
    
    println("Last positions - \(inter1LastPos) - \(inter2LastPos) - \(answerLastPos)")
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, "\(operand1)乘\(operand2)等如幾多")

    setupScreen()
  }

  func setupScreen() {
    var tmpTextField: UITextField
    var tmpLabel: UILabel
    
    // Hide the compelete image
    completeImage.hidden = true
    
    // Clear the intermediate result fields
    for i in (0...4) {
      tmpTextField = view.viewWithTag(inter1StartTag + i) as! UITextField
      if i == 0 {
        tmpTextField.text = "0"
      } else {
        tmpTextField.text = ""
      }
      if operand2 >= 10 && i == 1 {   // remember the first field is always zero and cannot be edited
        tmpTextField.enabled = true
        tmpTextField.setFieldStyle(FieldStyle.Active)
      } else {
        tmpTextField.enabled = false
        tmpTextField.setFieldStyle(FieldStyle.Inactive)
      }
      
      // Hide fields that are not needed
      if inter1Array[i] != " " {
        tmpTextField.hidden = false
      } else {
        tmpTextField.hidden = true
      }

      tmpTextField = view.viewWithTag(inter2StartTag + i) as! UITextField
      tmpTextField.text = ""
      tmpTextField.enabled = false
      tmpTextField.setFieldStyle(FieldStyle.Inactive)

      // Hide fields that are not needed
      if inter2Array[i] != " " {
        tmpTextField.hidden = false
      } else {
        tmpTextField.hidden = true
      }
    }
    
    // Clear the answer fields
    for i in (0...5) {
      tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
      tmpTextField.text = ""
      if operand2 < 10 && i == 0 {
        tmpTextField.enabled = true
        tmpTextField.setFieldStyle(FieldStyle.Active)
      } else {
        tmpTextField.enabled = false
        tmpTextField.setFieldStyle(FieldStyle.Inactive)
      }
      
      // Hide fields that are not needed
      if answerArray[i] != " " {
        tmpTextField.hidden = false
      } else {
        tmpTextField.hidden = true
      }
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
      if tmpLabel.text == " " {
        tmpLabel.hidden = true
      } else {
        tmpLabel.hidden = false
      }
    }

    // Show/Hide the divider line and shift answer fields up if necessary
    if operand2 >= 10 {
      dividerView.hidden = false
      for i in (0...5) {
        tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
        tmpTextField.center.y = 572   // original position
      }
    } else {
      dividerView.hidden = true
      for i in (0...5) {
        tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
        tmpTextField.center.y = 342   // shift up if no intermediate operands
      }
    }
    
    // Setup accessibility labels
    questionLabel.accessibilityLabel = "\(operand1)乘\(operand2)等如幾多?"
    finalAnswerStr = "答對啦"
    finalAnswerStr = finalAnswerStr + "\(operand1)乘\(operand2)等如" + String(answer)
    // Display the intermediate result for checking
//    if operand2 >= 10 {
//      for i in (0...4) {
//        tmpTextField = view.viewWithTag(inter1StartTag + i) as! UITextField
//        tmpTextField.text = String(inter1Array[i])
//        tmpTextField = view.viewWithTag(inter2StartTag + i) as! UITextField
//        tmpTextField.text = String(inter2Array[i])
//      }
//    }
    
    // Display the answer
//    for i in (0...5) {
//      tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
//      tmpTextField.text = String(answerArray[i])
//    }
  }
  
  func checkResult() {
    var startTag: Int = 0
    var lastPos: Int = 0
    var valueArray: [String] = [""]
    var tmpTextField: UITextField
    
    if isCancelInput {
      isCancelInput = false
      return
    }
    
    switch currRow {
    case 1:
      startTag = inter1StartTag
      lastPos = inter1LastPos
      valueArray = inter1Array
    case 2:
      startTag = inter2StartTag
      lastPos = inter2LastPos
      valueArray = inter2Array
    case 3:
      startTag = answerStartTag
      lastPos = answerLastPos
      valueArray = answerArray
    default:
      break
    }
    
    tmpTextField = self.view.viewWithTag(startTag + currPos - 1) as! UITextField
    
    if tmpTextField.text != valueArray[currPos - 1] {
      tmpTextField.text = ""
      tmpTextField.becomeFirstResponder()
      AppUtil.playEffect(SoundEffect.AnswerIncorrect)
      return
    }
    
    tmpTextField.enabled = false
    tmpTextField.setFieldStyle(FieldStyle.Inactive)
    
    // Advance to the next field
    if currPos < lastPos {
      currPos++
      tmpTextField = self.view.viewWithTag(startTag + currPos - 1) as! UITextField
      tmpTextField.enabled = true
      tmpTextField.setFieldStyle(FieldStyle.Active)
      tmpTextField.becomeFirstResponder()
    } else {
      if currRow == 3 {
        println("Complete la")
        AppUtil.playEffect(SoundEffect.AnswerCorrect)
        AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)
        completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        completeImage.hidden = false
        NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
      } else {
        currRow++
        currPos = 1
        
        if currRow == 2 {
          tmpTextField = self.view.viewWithTag(inter2StartTag + currPos - 1) as! UITextField
        } else {
          tmpTextField = self.view.viewWithTag(answerStartTag + currPos - 1) as! UITextField
        }
        tmpTextField.enabled = true
        tmpTextField.setFieldStyle(FieldStyle.Active)
        tmpTextField.becomeFirstResponder()
      }
    }
    tmpTextField.becomeFirstResponder()
  }
  
  func redoBtnClicked() {
    currPos = orgPos
    currRow = orgRow
    setupScreen()
  }

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
        tmpTextField.text = String(keyReceived.rawValue)
        tmpTextField.resignFirstResponder()
        AppUtil.sayIt(tmpTextField.text)
      } else {
        AppUtil.sayIt(Voices.fieldIsFull)
      }

      // Key the VO focus on the original key
//      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .Delete:
      tmpTextField.text = ""
    case .Cancel:
      tmpTextField.text = currFieldText
      isCancelInput = true
      tmpTextField.resignFirstResponder()
//      view.accessibilityElementsHidden = false
      NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
    case .Confirm:
      tmpTextField.resignFirstResponder()
//      view.accessibilityElementsHidden = false
      NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
    default:
      tmpTextField.resignFirstResponder()
    }
  }
}
