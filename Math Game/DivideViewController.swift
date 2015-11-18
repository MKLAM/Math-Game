//
//  DivideViewController.swift
//  Math Game
//
//  Created by Richard on 9/20/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class DivideViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var divider1Image: UIImageView!
  @IBOutlet weak var divider2Image: UIImageView!
  @IBOutlet weak var divider3Image: UIImageView!
  
  @IBOutlet weak var completeImage: UIImageView!
  @IBOutlet weak var gridImage: UIImageView!
  
  
  // Keep track of starting field tags
  let operand1StartTag = 1
  let operand2StartTag = 11
  let answerStartTag = 21
  let interStartTag = 31
  
  var operand1 = 0
  var operand2 = 0
  var answer = 0
  var remainder = 0
  var operand1Array = [String](count: 3, repeatedValue: "")
  var operand2Array = [String](count: 3, repeatedValue: "")
  var interArray = [String](count:18, repeatedValue:"")
  var answerArray = [String](count: 3, repeatedValue: "")
  var remainderArray = [String](count: 3, repeatedValue: "")
  
  var currField = 0
  var currFieldText = ""
  
  var atAnswerField = true   // keep track of where the current field is
  var atAnswerPos = 0
  var atInterPos = 0
  
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
    for i in (0...17) {
      tmpTextField = view.viewWithTag(interStartTag + i) as! UITextField
      tmpTextField.inputView = AppUtil.createKeyboardView(holdObj)
    }
    
    // Assign custom keyboard to the answer fields
    for i in (0...2) {
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
    AppUtil.log("Into Divide")
    difficultyLevel = level
    
    atAnswerField = true
    atAnswerPos = 0
    atInterPos = 0
    
    operand1Array = ["", ""]
    operand2Array = ["",  "", ""]
    answerArray = ["", "", ""]
    remainderArray = ["", "", ""]
    interArray = [String](count:18, repeatedValue:"")

    if difficultyLevel == DifficultyLevel.Easy || difficultyLevel == DifficultyLevel.Difficult {
      do {
        if difficultyLevel == DifficultyLevel.Easy {
          operand1 = Int(arc4random_uniform(longCalcParam.divideOp1Easy)) + 2
          operand2 = Int(arc4random_uniform(longCalcParam.divideOp2Easy)) + 1
        } else {
          operand1 = Int(arc4random_uniform(longCalcParam.divideOp1Difficult)) + 2
          operand2 = Int(arc4random_uniform(longCalcParam.divideOp2Difficult)) + 1
        }
      } while operand1 > operand2 ||
              difficultyLevel == DifficultyLevel.Difficult && operand2/10 < operand1
      
    } else {   // custom question
      operand1 = customOperand2
      operand2 = customOperand1
    }
    
    answer = operand2 / operand1
    remainder = operand2 % operand1
    
    
    println("Solve \(operand1) / \(operand2) = \(answer) \(remainder)")
    
    // Setup the operand arrays
    var counter = 0
    var tmpString: String
    
    tmpString = String(operand1)
    while count(tmpString) < 2 {
      tmpString = " " + tmpString
    }
    
    counter = 0
    for c in tmpString {
      operand1Array[counter] = String(c) == " " ? "" : String(c)
      counter++
    }
    
    tmpString = String(operand2)
    
    counter = 0
    for c in tmpString {
      operand2Array[counter] = String(c) == " " ? "" : String(c)
      counter++
    }
    
    // Setup the answer array
    tmpString = String(answer)
    while count(tmpString) < count(String(operand2)) {
      tmpString = " " + tmpString
    }
    
    counter = 0
    for c in tmpString {
      answerArray[counter] = String(c) == " " ? "" : String(c)
      counter++
    }
    
    // Setup the remainder array
    tmpString = String(remainder)
    while Int(count(tmpString)) < 3 {
      tmpString = " " + tmpString
    }
    
    counter = 0
    for c in tmpString {
      remainderArray[counter] = String(c) == " " ? "" : String(c)
      counter++
    }
    
    // Setup the intermediate result array
    var tmpRow = 0
    var tmpValue1 = 0
    var tmpValue2 = 0
    var tmpValue3 = 0
    var tmpValue4 = 0
    var doneFirst = false
    var doneSecond = false
    
    counter = 0
    tmpString = String(answer)
    while count(tmpString) < count(String(operand2)) {
      tmpString = " " + tmpString
    }
    
    // Iterate through each character in answer
    for c in tmpString {
//      if String(c) != " " && String(c) != "0" {
      if String(c) != " " {
        // Handle the inner product
        var tmpString2 = String(String(c).toInt()! * operand1)
        tmpValue1 = tmpString2.toInt()!
        // Determine if string needs padding
        if !(counter == 0) &&
          !(counter == 1 && count(tmpString2) == 2) &&
          !(count(tmpString2) == 3) {
            if counter == 1 {
              tmpString2 = " " + tmpString2
            } else {
              if count(tmpString2) == 1 {
                tmpString2 = "  " + tmpString2
              } else {
                tmpString2 = " " + tmpString2
              }
            }
        }
        var count2 = 0
        for c2 in tmpString2 {
          interArray[tmpRow * 2 * 3 + count2] = String(c2) == " " ? "" : String(c2)
          count2++
        }

        // Handle the inner remainder
        if doneFirst && !doneSecond {
          // Second digit of answer
          println("do second \(tmpValue4) - \(tmpValue1)")
          tmpString2 = String(tmpValue4 - tmpValue1)
          
          // Pad the remainder
          var padTimes = counter + 1 - count(tmpString2)
          for var i = 0; i < padTimes; i++ {
            tmpString2 = " " + tmpString2
          }

          // Bring down next digit
          if counter == 1 && count(String(operand2)) == 3 {
            tmpString2 += operand2Array[2]
          }

          if tmpString2 == "  0" || tmpString2 == " 0" {   // this won't be necessary
            tmpString2 = "   "
          }
          
          count2 = 0
          for c2 in tmpString2 {
            interArray[(tmpRow + 2) * 3 + count2] = String(c2) == " " ? "" : String(c2)
            count2++
          }
          
          doneSecond = true
        }

        // Handle the first digit of the answer
        if !doneFirst {
          AppUtil.log("do first -  count = \(counter)")
// This part not sure if needed
//          if tmpValue1 < 10 {
//            if count != 0 {
//              tmpValue1 *= 10
//            }
//          }

          // Get the left most digits
          if counter == 0 {
            // Get 1 digit
            if operand2 > 100 {
              tmpValue2 = operand2 / 100
            } else if operand2 > 10 {
              tmpValue2 = operand2 / 10
            } else {
              tmpValue2 = operand2
            }
          } else if counter == 1 {
            // Get 2 digits
            tmpValue2 = operand2 > 100 ? operand2 / 10 : operand2
          } else {
            tmpValue2 = operand2
          }

          tmpValue3 = tmpValue2 - tmpValue1
          tmpValue4 = tmpValue3
          AppUtil.log("\(tmpValue2) - \(tmpValue1) - \(tmpValue3)")
          tmpString2 = String(tmpValue3)
          
          //--------------------------------------------------------------------------------------------------------------
          // Not sure what's wrong with the following code
          if tmpValue3 != 0 {
            // Pad the remainder
            var padTimes = counter + 1 - Int(count(tmpString2))
            for var i = 0; i < padTimes; i++ {
              tmpString2 = " " + tmpString2
            }

            // Bring in next digit
            if tmpValue3 < operand1 && count(String(operand2)) > (counter+1) {
                tmpString2 = tmpString2 + operand2Array[counter+1]
                tmpValue4 = tmpValue4 * 10 + operand2Array[counter+1].toInt()!
            }
          } else {
            tmpString2 = " "  // don't show the leading zero
            if counter == 0 && count(String(operand2)) > 1 {
//              tmpString2 = tmpString2 + operand2Array[1]
              tmpString2 += operand2Array[1]
              tmpValue4 = operand2Array[1].toInt()!
            }
            if counter == 1 && count(String(operand2)) > 2 {
//              tmpString2 = " " + tmpString2 + operand2Array[2]
              tmpString2 += " " + operand2Array[2]
              tmpValue4 = operand2Array[2].toInt()!
            }
          }
          
//          if tmpString2 == "  0" || tmpString2 == " 0" || tmpString2 == "0 " || tmpString2 == "0" {   // this won't be necessary
//            tmpString2 = "   "
//          }
          
          count2 = 0
          for c2 in tmpString2 {
            interArray[(tmpRow + 1) * 3 + count2] = String(c2) == " " ? "" : String(c2)
            count2++
          }
          
          doneFirst = true
        }

        // Advance to the next row
        tmpRow++
      }

      // Next digit of answer
      counter++
    }

    // Handle the remainder if it is at the last row
    if remainder > 0 && interArray[14] != "" {
      for i in 0...2 {
        interArray[15 + i] = remainderArray[i]
      }
    }
  
    setupScreen()
  }
  
  func setupScreen() {
    var tmpTextField: UITextField
    var tmpLabel: UILabel
    
    // Hide the compelete image
    completeImage.hidden = true
    
    // Clear the answer fields
    for i in (0...2) {
      tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
      tmpTextField.text = ""
      tmpTextField.enabled = false
      tmpTextField.setFieldStyle(FieldStyle.Inactive)
    }
    
    // Display the operand fields
    for i in (0...1) {
      tmpLabel = view.viewWithTag(operand1StartTag + i) as! UILabel
      tmpLabel.text = String(operand1Array[i])
      tmpLabel.accessibilityLabel = tmpLabel.text!
      switch i {
      case 0:
        if operand1 > 10 {
          tmpLabel.accessibilityLabel = tmpLabel.text! + "十"
        }
      default:
        break
      }
      if tmpLabel.text == " " {
        tmpLabel.hidden = true
      } else {
        tmpLabel.hidden = false
      }
    }
    for i in (0...2) {
      tmpLabel = view.viewWithTag(operand2StartTag + i) as! UILabel
      tmpLabel.text = String(operand2Array[i])
      tmpLabel.accessibilityLabel = tmpLabel.text!
      switch i {
      case 0:
        if operand2 >= 100 {
          tmpLabel.accessibilityLabel = tmpLabel.accessibilityLabel + "百"
        } else if operand2 >= 10 {
          tmpLabel.accessibilityLabel = tmpLabel.accessibilityLabel + "十"
        }
      case 1:
        if operand2 >= 100 {
          tmpLabel.accessibilityLabel = tmpLabel.accessibilityLabel + "十"
        }
      default:
        break
      }
      if tmpLabel.text == " " {
        tmpLabel.hidden = true
      } else {
        tmpLabel.hidden = false
      }
    }

    // Display the answer field
    for i in (0...2) {
      tmpTextField = view.viewWithTag(answerStartTag + i) as! UITextField
//      tmpTextField.text = String(answerArray[i])   // show answers
      tmpTextField.text = ""
      tmpTextField.enabled = false
      tmpTextField.setFieldStyle(FieldStyle.Inactive)
      
      // Hide fields that are not needed
      if answerArray[i] != "" {
        tmpTextField.hidden = false
      } else {
        tmpTextField.hidden = true
      }
    }

    // Display the intermediate fields
    for i in (0...17) {
      tmpTextField = view.viewWithTag(interStartTag + i) as! UITextField
//      tmpTextField.text = String(interArray[i])   // show answers
      tmpTextField.text = ""
      tmpTextField.enabled = false
      tmpTextField.setFieldStyle(FieldStyle.Inactive)
      
      // Hide fields that are not needed
      if interArray[i] != "" {
        tmpTextField.hidden = false
      } else {
        tmpTextField.hidden = true
      }
    }
    
    // Show/Hide the dividing lines
    divider1Image.hidden = true
    divider2Image.hidden = true
    divider3Image.hidden = true

    var displayLine = false
    var lineSegment = 0
    var lineStartX = 0
    let lineWidth = 74
    let lineHeight = 12
    let startX = [379, 454, 529]
    let startY = [300, 452, 604]
//    if !(interArray[3] == "" && interArray[4] == "" && interArray[5] == "") {  // don't show the last dividing line
    if true {
      if interArray[0] != "" || interArray[3] != "" {
        displayLine = true
        lineSegment++
        lineStartX = startX[0]
      }
      
      if interArray[1] != "" || interArray[4] != "" {
        lineSegment++
        if !displayLine {
          displayLine = true
          lineStartX = startX[1]
        }
      }
      
      if interArray[2] != "" || interArray[5] != "" {
        lineSegment++
        if !displayLine {
          displayLine = true
          lineStartX = startX[2]
        }
      }
    }
    if displayLine {
      divider1Image.hidden = false
      divider1Image.frame = CGRectMake(CGFloat(lineStartX), CGFloat(startY[0]), CGFloat(lineSegment * lineWidth), CGFloat(lineHeight))
    }

    displayLine = false
    lineSegment = 0
//    if !(interArray[9] == "" && interArray[10] == "" && interArray[11] == "") {
    if true {
      if interArray[6] != "" || interArray[9] != "" {
        displayLine = true
        lineSegment++
        lineStartX = startX[0]
      }
      
      if interArray[7] != "" || interArray[10] != "" {
        lineSegment++
        if !displayLine {
          displayLine = true
          lineStartX = startX[1]
        }
      }
      
      if interArray[8] != "" || interArray[11] != "" {
        lineSegment++
        if !displayLine {
          displayLine = true
          lineStartX = startX[2]
        }
      }
    }
    if displayLine {
      divider2Image.hidden = false
      divider2Image.frame = CGRectMake(CGFloat(lineStartX), CGFloat(startY[1]), CGFloat(lineSegment * lineWidth), CGFloat(lineHeight))
    }

    displayLine = false
    lineSegment = 0
//    if !(interArray[15] == "" && interArray[16] == "" && interArray[17] == "") {
    if true {
      if interArray[12] != "" || interArray[15] != "" {
        displayLine = true
        lineSegment++
        lineStartX = startX[0]
      }
      
      if interArray[13] != "" || interArray[16] != "" {
        lineSegment++
        if !displayLine {
          displayLine = true
          lineStartX = startX[1]
        }
      }
      
      if interArray[14] != "" || interArray[17] != "" {
        lineSegment++
        if !displayLine {
          displayLine = true
          lineStartX = startX[2]
        }
      }
    }
    if displayLine {
      divider3Image.hidden = false
      divider3Image.frame = CGRectMake(CGFloat(lineStartX), CGFloat(startY[2]), CGFloat(lineSegment * lineWidth), CGFloat(lineHeight))
    }
    
    // Enable the first field
    atAnswerPos = 0
    tmpTextField = view.viewWithTag(answerStartTag) as! UITextField
    while String(answerArray[atAnswerPos]) == "" {
      atAnswerPos++
      tmpTextField = view.viewWithTag(answerStartTag + atAnswerPos) as! UITextField
    }
    tmpTextField.enabled = true
    tmpTextField.setFieldStyle(FieldStyle.Active)
    switch answerStartTag + atAnswerPos {
    case answerStartTag:
      if answerArray[atAnswerPos+1] != "" && answerArray[atAnswerPos+2] != "" {
        tmpTextField.accessibilityLabel = "請輸入商的百位"
      } else if answerArray[1] != "" {
        tmpTextField.accessibilityLabel = "請輸入商的十位"
      } else {
        tmpTextField.accessibilityLabel = "請輸入商的個位"
      }
    case answerStartTag+1:
      if answerArray[atAnswerPos+1] != "" {
        tmpTextField.accessibilityLabel = "請輸入商的十位"
      } else {
        tmpTextField.accessibilityLabel = "請輸入商的個位"
      }
    case answerStartTag+2:
      tmpTextField.accessibilityLabel = "請輸入商的個位"
    default:
      AppUtil.log("Should not happen")
    }
    
    // Setup accessibility labels
    questionLabel.accessibilityLabel = "\(operand2)除\(operand1)等如幾多?"
    finalAnswerStr = "答對啦"
    finalAnswerStr = finalAnswerStr + "\(operand2)除\(operand1)等如" + String(answer)
    if (remainder > 0) {
      finalAnswerStr = finalAnswerStr + "餘數係 \(remainder)"
    }
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, questionLabel)
  }
  
  func checkResult() {
    var tmpTextField: UITextField
    tmpTextField = view.viewWithTag(currField) as! UITextField

    if isCancelInput {
      isCancelInput = false
      return
    }

    // Stay at current field and play sound effect if input is incorrect
    if (atAnswerField && tmpTextField.text != answerArray[atAnswerPos]) ||
       (!atAnswerField && tmpTextField.text != interArray[atInterPos]) {
      tmpTextField.text = ""
      tmpTextField.becomeFirstResponder()
      AppUtil.playEffect(SoundEffect.AnswerIncorrect)
      return
    }
    
    tmpTextField.enabled = false
    tmpTextField.setFieldStyle(FieldStyle.Inactive)
    
    // Update the accessibility label of the field just filled
    if atAnswerField {
      switch currField {
      case answerStartTag:
        if answerArray[atAnswerPos+1] != "" && answerArray[atAnswerPos+2] != "" {
          tmpTextField.accessibilityLabel = "商的百位"
        } else if answerArray[1] != "" {
          tmpTextField.accessibilityLabel = "商的十位"
        } else {
          tmpTextField.accessibilityLabel = "商的個位"
        }
      case answerStartTag+1:
        if answerArray[atAnswerPos+1] != "" {
          tmpTextField.accessibilityLabel = "商的十位"
        } else {
          tmpTextField.accessibilityLabel = "商的個位"
        }
      case answerStartTag+2:
        tmpTextField.accessibilityLabel = "商的個位"
      default:
        AppUtil.log("Should not happen")
      }
    } else {
      switch currField {
      case interStartTag, interStartTag+3, interStartTag+6, interStartTag+9, interStartTag+12, interStartTag+15:
        if interArray[atInterPos+1] != "" && interArray[atInterPos+2] != "" {
          tmpTextField.accessibilityLabel = "中間數百位"
        } else if interArray[atInterPos+1] != "" {
          tmpTextField.accessibilityLabel = "中間數十位"
        } else {
          tmpTextField.accessibilityLabel = "中間數個位"
        }
      case interStartTag+1, interStartTag+4, interStartTag+7, interStartTag+10, interStartTag+13, interStartTag+16:
        if interArray[atInterPos+1] != "" {
          tmpTextField.accessibilityLabel = "中間數十位"
        } else {
          tmpTextField.accessibilityLabel = "中間數個位"
        }
      case interStartTag+2, interStartTag+5, interStartTag+8, interStartTag+11, interStartTag+14, interStartTag+17:
        tmpTextField.accessibilityLabel = "中間數個位"
      default:
        AppUtil.log("Should not happen")
      }
    }
    
    if atAnswerField {
      // Move to intermediate result fields
      atAnswerField = false
      
      // Find the next non empty field
      if atInterPos != 0 {
        atInterPos++
      }

      tmpTextField = view.viewWithTag(interStartTag + atInterPos) as! UITextField
      while String(interArray[atInterPos]) == "" {
        atInterPos++
        if atInterPos == 18 {
          println("Complete la 1")
          AppUtil.playEffect(SoundEffect.AnswerCorrect)
          AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)
          completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
          completeImage.hidden = false
          NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
          return
        }
        tmpTextField = view.viewWithTag(interStartTag + atInterPos) as! UITextField
      }
      
      tmpTextField.enabled = true
      tmpTextField.setFieldStyle(FieldStyle.Active)
      tmpTextField.becomeFirstResponder()
    } else {
      // Check if need to move back to answer fields
      if (atInterPos / 3) % 2 == 1 {  // switch is only possible on odd rows
        switch atInterPos % 3 {
        case 0:
          if String(interArray[atInterPos + 1]) == "" && String(interArray[atInterPos + 2]) == "" {
              atAnswerField = true
          }
        case 1:
          if String(interArray[atInterPos + 1]) == "" {
              atAnswerField = true
          }
        case 2:
          atAnswerField = true
        default:
          break
        }
        
        if atInterPos % 3 > atAnswerPos {
          atAnswerField = true
        }
      }
      
      if atAnswerField {
        atAnswerPos++
        if atAnswerPos == 3 || String(answerArray[atAnswerPos]) == "" {
          println("Complete la 2")
          AppUtil.playEffect(SoundEffect.AnswerCorrect)
          AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)
          completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
          completeImage.hidden = false
          NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
          return
        } else {
          (view.viewWithTag(answerStartTag + atAnswerPos) as! UITextField).enabled = true
          (view.viewWithTag(answerStartTag + atAnswerPos) as! UITextField).setFieldStyle(FieldStyle.Active)
          (view.viewWithTag(answerStartTag + atAnswerPos) as! UITextField).becomeFirstResponder()
        }
      } else {
        atInterPos++
        if atInterPos == 18 {
          println("Complete la 3")
          AppUtil.playEffect(SoundEffect.AnswerCorrect)
          AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)
          completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
          completeImage.hidden = false
          NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
          return
        }
        tmpTextField = view.viewWithTag(interStartTag + atInterPos) as! UITextField
        while String(interArray[atInterPos]) == "" {
          atInterPos++
          if atInterPos == 18 {
            println("Complete la 4")
            AppUtil.playEffect(SoundEffect.AnswerCorrect)
            AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)
            completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            completeImage.hidden = false
            NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
            return
          }
          tmpTextField = view.viewWithTag(interStartTag + atInterPos) as! UITextField
        }
        
        tmpTextField.enabled = true
        tmpTextField.setFieldStyle(FieldStyle.Active)
        tmpTextField.becomeFirstResponder()
      }
    }
    
    // Set the accessibility label of the current input field
    if atAnswerField {
      tmpTextField = view.viewWithTag(answerStartTag + atAnswerPos) as! UITextField
      switch answerStartTag + atAnswerPos {
      case answerStartTag:
        if answerArray[atAnswerPos+1] != "" && answerArray[atAnswerPos+2] != "" {
          tmpTextField.accessibilityLabel = "請輸入商的百位"
        } else if answerArray[1] != "" {
          tmpTextField.accessibilityLabel = "請輸入商的十位"
        } else {
          tmpTextField.accessibilityLabel = "請輸入商的個位"
        }
      case answerStartTag+1:
        if answerArray[atAnswerPos+1] != "" {
          tmpTextField.accessibilityLabel = "請輸入商的十位"
        } else {
          tmpTextField.accessibilityLabel = "請輸入商的個位"
        }
      case answerStartTag+2:
        tmpTextField.accessibilityLabel = "請輸入商的個位"
      default:
        AppUtil.log("Should not happen")
      }
    } else {
      tmpTextField = view.viewWithTag(interStartTag + atInterPos) as! UITextField
      switch interStartTag + atInterPos {
      case interStartTag, interStartTag+3, interStartTag+6, interStartTag+9, interStartTag+12, interStartTag+15:
        if interArray[atInterPos+1] != "" && interArray[atInterPos+2] != "" {
          tmpTextField.accessibilityLabel = "請輸入中間數百位"
        } else if interArray[atInterPos+1] != "" {
          tmpTextField.accessibilityLabel = "請輸入中間數十位"
        } else {
          tmpTextField.accessibilityLabel = "請輸入中間數個位"
        }
      case interStartTag+1, interStartTag+4, interStartTag+7, interStartTag+10, interStartTag+13, interStartTag+16:
        if interArray[atInterPos+1] != "" {
          tmpTextField.accessibilityLabel = "請輸入中間數十位"
        } else {
          tmpTextField.accessibilityLabel = "請輸入中間數個位"
        }
      case interStartTag+2, interStartTag+5, interStartTag+8, interStartTag+11, interStartTag+14, interStartTag+17:
        tmpTextField.accessibilityLabel = "請輸入中間數個位"
      default:
        AppUtil.log("Should not happen")
      }
    }
  }
  
  func redoBtnClicked() {
    atAnswerField = true
    atAnswerPos = 0
    atInterPos = 0
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
  
  // Create custom keyboard view
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
        AppUtil.sayIt(tmpTextField.text)
        tmpTextField.resignFirstResponder()
//        view.accessibilityElementsHidden = false
//        NSNotificationCenter.defaultCenter().postNotificationName("endEditing", object:nil, userInfo:nil)
      } else {
        AppUtil.sayIt(Voices.fieldIsFull)
      }

      // Key the VO focus on the original key
//      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(0))
    case .Delete:
      tmpTextField.text = ""
    case .Cancel:
      tmpTextField.text = currFieldText
      isCancelInput = true   // need to set this first, or will run checkResult() first
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
  
//  func customKeyboardBtnClicked(sender: UIButton!) {
//    // Get a reference to the current field
//    var tmpTextField = UITextField()
//    tmpTextField = self.view.viewWithTag(currField) as! UITextField
//    
//    // Tag 0..9 = 0..9, 21 = confirm, 22 = cancel
//    switch sender!.tag {
//    case 0...9:
//      // Append only if field is empty
//      if tmpTextField.text.utf16Count == 0 {
//        tmpTextField.text = String(sender!.tag)
//      } else {
//        // Notify user
//        AppUtil.log("Max length la")
//      }
//    case 21:   // confirm
//      tmpTextField.resignFirstResponder()
//    case 22:   // cancel
//      tmpTextField.text = currFieldText
//      tmpTextField.resignFirstResponder()
//    default:
//      tmpTextField.resignFirstResponder()
//    }
//  }
}
