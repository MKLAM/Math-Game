//
//  AlgebraViewController.swift
//  Math Game
//
//  Created by Richard on 9/23/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class AlgebraViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet var questionLabel: UILabel!
  @IBOutlet var stepLabel: UILabel!
  @IBOutlet var leftOperand1: UITextField!
  @IBOutlet var leftOpImage: UIImageView!
  @IBOutlet var leftOperand2: UITextField!
  @IBOutlet var rightOperand1: UITextField!
  @IBOutlet var rightOpImage: UIImageView!
  @IBOutlet var rightOperand2: UITextField!
  @IBOutlet weak var answer1Text: UITextField!
  @IBOutlet weak var answer2Text: UITextField!
  
  @IBOutlet weak var leftAnswer1Text: UITextField!
  @IBOutlet weak var leftOpText: UITextField!
  @IBOutlet weak var leftAnswer2Text: UITextField!
  @IBOutlet weak var rightAnswer1Text: UITextField!
  @IBOutlet weak var rightOpText: UITextField!
  @IBOutlet weak var rightAnswer2Text: UITextField!
  @IBOutlet weak var directEqualImage: UIImageView!
  
  @IBOutlet weak var s1Label: UILabel!
  @IBOutlet weak var s2Label: UILabel!
  
  @IBOutlet weak var completeImage: UIImageView!
  @IBOutlet weak var gridView: UIView!
  @IBOutlet weak var gridImage: UIImageView!
  
  @IBOutlet weak var completeBtn: UIButton!
  @IBOutlet weak var nextQuestionBtn: UIButton!
  
  struct OperandStruct {
    var value: Int
    var hasX: Bool
  }
  
  var stepValues: [[OperandStruct]] = [[]]
  var stepOps: [[String]] = [[]]
  var currStep = 1
  var currPage = 1
  var currField = 0
  var currFieldText = ""
  var operand1: OperandStruct = OperandStruct(value: 0, hasX: false)
  var operand2: OperandStruct = OperandStruct(value: 0, hasX: false)
  var operand3: OperandStruct = OperandStruct(value: 0, hasX: false)
  var operand4: OperandStruct = OperandStruct(value: 0, hasX: false)
  var leftOp = ""
  var rightOp = ""
  var answer = 0
  var almostFinished = false
  var isFinished = false
  
  var enterSign = ""
  var enterValue = ""
  var enterX = ""
  
  var finalAnswerStr = ""
  
  var difficultyLevel = DifficultyLevel.Easy
  var holdObj = RetainObj()
  var solveWith = SolveMethod.Balance
  
  var questionsBank = []
  
  let algebraParam = AlgebraParam()
  
  // MARK: - View
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leftOperand1.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    leftOperand2.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    rightOperand1.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    rightOperand2.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    answer1Text.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    answer2Text.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    leftAnswer1Text.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    leftAnswer2Text.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    leftOpText.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    rightAnswer1Text.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    rightAnswer2Text.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    rightOpText.inputView = AppUtil.createKeyboardView(holdObj, withOp: true, withX: true)
    
    // Read in the question bank
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0) as! NSString
    let filePath = documentsDirectory.stringByAppendingPathComponent("AlgebraQuestions.plist")
    
    questionsBank = NSArray(contentsOfFile: filePath)!
    println("There are \(questionsBank.count) questions for algebra")

    // Listen to keyPressed
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyPressed:", name: "keyPressed", object: nil)
    
    nextQuestionBtnClicked(0)
  }
  
  override func viewDidAppear(animated: Bool) {
    let userDefaults = NSUserDefaults()
    
    super.viewDidAppear(animated)
    
    AppUtil.setCustomColors(view)
    if userDefaults.objectForKey("displayGrid") as! Bool {
      gridView.hidden = false
      gridView.accessibilityElementsHidden = false
      gridImage.hidden = false
      gridImage.image = gridImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    } else {
      gridView.hidden = true
      gridView.accessibilityElementsHidden = true
      gridImage.hidden = true
    }
  }

  
  // MARK: - Screen buttons
  
  @IBAction func backBtnClicked(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func nextQuestionBtnClicked(sender: AnyObject) {
    genNewQuestion()
  }
  
  @IBAction func redoBtnClicked(sender: AnyObject) {
    currStep = 1
    currPage = 1
    almostFinished = false
    isFinished = false
    
    let tmpValue = stepValues[0]
    operand1 = tmpValue[0]
    operand2 = tmpValue[1]
    operand3 = tmpValue[2]
    operand4 = tmpValue[3]
    
    stepValues =  [[OperandStruct]]()
    stepValues.append(tmpValue)
    
    let tmpOp = stepOps[0]
    leftOp = tmpOp[0]
    rightOp = tmpOp[1]
    
    stepOps = [[String]]()
    stepOps.append(tmpOp)
    
    setupScreen()
  }
  
  @IBAction func prevPageBtnClicked(sender: AnyObject) {
    goPrevPage()
  }
  
  @IBAction func nextPageBtnClicked(sender: AnyObject) {
    goNextPage()
  }
  
  @IBAction func completeBtnClicked(sender: AnyObject) {
    var trueValue = 0
    
    // Need to make sure format of answer is valid
    if enterValue == "" {
      AppUtil.log("Incorrect answer format")
    }
    
    if solveWith == SolveMethod.Balance {
      if !almostFinished {
        // Must enter both fields the same
        if answer1Text.text != answer2Text.text {
          AppUtil.playEffect(SoundEffect.AnswerIncorrect)
          AppUtil.log("Not the same")
          return
        }
        
        // Check for invalid entries
        if answer1Text.text == "-" || answer1Text.text == "+" || enterValue == "0" || enterSign == "/" ||
           !(answer1Text.text.hasPrefix("+") || answer1Text.text.hasPrefix("-") || answer1Text.text.hasPrefix("/")){
          AppUtil.playEffect(SoundEffect.AnswerIncorrect)
          AppUtil.log("Invalid input format")
          return
        }
        
        if enterSign == "+" {
          trueValue = enterValue.toInt()!
        } else {
          trueValue = enterValue.toInt()! * -1
        }
        
        // Combine the answer with the existing operands
        // Left side
        if leftOp == "-" {
          operand2.value *= -1
        }
        if enterX == "x" {
          if operand1.hasX {
            operand1.value += trueValue
          } else if operand2.hasX {
            operand2.value += trueValue
          } else {
            if operand1.value == 0 {
              operand1.value = trueValue
              operand1.hasX = true
            } else {
              operand2.value = trueValue
              operand2.hasX = true
            }
          }
          if operand1.value == 0 {
            operand1.hasX = false
          }
          if operand2.value == 0 {
            operand2.hasX = false
          }
        } else {
          if !operand1.hasX && operand1.value != 0 {
            operand1.value += trueValue
          } else if !operand2.hasX && operand2.value != 0 {
            operand2.value += trueValue
          } else {
            if operand1.value == 0 {
              operand1.value = trueValue
              operand1.hasX = false
            } else {
              operand2.value = trueValue
              operand2.hasX = false
            }
          }
        }

        // If operand2 is empty, move operand1 over
        if operand2.value == 0 {
          operand2.value = operand1.value
          operand2.hasX = operand1.hasX
          operand1.value = 0
          operand1.hasX = false
        }
        
        // Fix operator
        if operand1.value == 0 || operand2.value == 0 {
          leftOp = ""
        } else {
          if operand2.value > 0 {
            leftOp = "+"
          } else {
            leftOp = "-"
            operand2.value *= -1
          }
        }
        
        // Right side
        if rightOp == "-" {
          operand4.value *= -1
        }
        if enterX == "x" {
          if operand3.hasX {
            operand3.value += trueValue
          } else if operand4.hasX {
            operand4.value += trueValue
          } else {
            if operand3.value == 0 {
              operand3.value = trueValue
              operand3.hasX = true
            } else {
              operand4.value = trueValue
              operand4.hasX = true
            }
          }
          if operand3.value == 0 {
            operand3.hasX = false
          }
          if operand4.value == 0 {
            operand4.hasX = false
          }
        } else {
          if !operand3.hasX && operand3.value != 0 {
            operand3.value += trueValue
          } else if !operand4.hasX && operand4.value != 0 {
            operand4.value += trueValue
          } else {
            if operand3.value == 0 {
              operand3.value = trueValue
              operand3.hasX = false
            } else {
              operand4.value = trueValue
              operand4.hasX = false
            }
          }
        }
        
        // If operand3 is empty, move operand4 over
        if operand3.value == 0 {
          operand3.value = operand4.value
          operand3.hasX = operand4.hasX
          operand4.value = 0
          operand4.hasX = false
        }

        // Fix operator
        if operand3.value == 0 || operand4.value == 0 {
          rightOp = ""
        } else {
          if operand4.value > 0 {
            rightOp = "+"
          } else {
            rightOp = "-"
            operand4.value *= -1
          }
        }
        
        answer1Text.text = ""
        answer2Text.text = ""
        completeBtn.enabled = false
      } else {  // almost finished
        // Must enter both fields the same
        if answer1Text.text != answer2Text.text {
          AppUtil.playEffect(SoundEffect.AnswerIncorrect)
          AppUtil.log("Not the same")
          return
        }
        
        // Check for answer
        if answer1Text.text != "÷" + String(operand2.value) {
            AppUtil.playEffect(SoundEffect.AnswerIncorrect)
            AppUtil.log("Incorrect answer")
            return
        } else {
          AppUtil.log("complete la")
          AppUtil.playEffect(SoundEffect.AnswerCorrect)
          AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)
          
          operand2.value = 1
          operand3.value = answer
          stepValues.append([operand1, operand2, operand3, operand4])
          stepOps.append(["", ""])
          currStep++
          currPage = currStep
          
          isFinished = true
          setupScreen()
          completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
          completeImage.hidden = false
          UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nextQuestionBtn)
          return
        }
      }
    }
    
    if solveWith == SolveMethod.Direct {
      var validated = true
      
      // If have operator, then both operands must be present
      if (leftOpText.text != "" && (leftAnswer1Text.text == "" || leftAnswer2Text.text == "")) ||
        (rightOpText.text != "" && (rightAnswer1Text.text == "" || rightAnswer2Text.text == "")) {
          AppUtil.log("Operand missing")
          validated = false
      }
      // Must have at least 1 variable
      if !leftAnswer1Text.text.hasSuffix("x") && !leftAnswer2Text.text.hasSuffix("x") &&
        !rightAnswer1Text.text.hasSuffix("x") && !rightAnswer2Text.text.hasSuffix("x") {
          AppUtil.log("No variable")
          validated = false
      }
      // Must have at least 1 number
      if leftAnswer1Text.text.hasSuffix("x") && leftAnswer2Text.text.hasSuffix("x") &&
        rightAnswer1Text.text.hasSuffix("x") && rightAnswer2Text.text.hasSuffix("x") {
          AppUtil.log("All variables")
          validated = false
      }
      // Must have something on each side
      if (leftOpText.text == "" && leftAnswer1Text.text == "" && leftAnswer2Text.text == "") ||
        (rightOpText.text == "" && rightAnswer1Text.text == "" && rightAnswer2Text.text == "") {
          AppUtil.log("Either side is all empty")
          validated = false
      }
      // Cannot divide by zero
      if (leftOpText.text == "÷" && leftAnswer2Text == "0") ||
        (rightOpText.text == "÷" && rightAnswer2Text == "0") {
          AppUtil.log("Divide by zero")
          validated = false
      }
      
      // Rules for last division operation
      //        if leftOpText.text == "÷" || rightOpText.text == "÷" {
      //          AppUtil.log("Invalid use of division")
      //          validated = false
      //        }
      
      // Check to see if the equation is still valid, no need to check for division step, must be valid
      var leftSide = 0
      var rightSide = 0
      var tmpValue = 0
      
      // Calculate left side
      if operand1.value != 0 {
        if operand1.hasX {
          leftSide += operand1.value * answer
        } else {
          leftSide += operand1.value
        }
      }
      if operand2.value != 0 {
        if operand2.hasX {
          tmpValue = operand2.value * answer
        } else {
          tmpValue = operand2.value
        }
        if leftOp == "-" {
          tmpValue *= -1
        }
        if leftOpText.text == "÷" {
          leftSide /= tmpValue
        } else {
          leftSide += tmpValue
        }
      }
      
      // Calculate right side
      if operand3.value != 0 {
        if operand3.hasX {
          rightSide += operand3.value * answer
        } else {
          rightSide += operand3.value
        }
      }
      tmpValue = 0
      if operand4.value != 0 {
        if operand4.hasX {
          tmpValue = operand4.value * answer
        } else {
          tmpValue = operand4.value
        }
        if rightOp == "-" {
          tmpValue *= -1
        }
        if rightOpText.text == "÷" {
          rightSide /= tmpValue
        } else {
          rightSide += tmpValue
        }
      }
      
      if leftSide != rightSide {
        AppUtil.log("Two sides not equal \(leftSide) -- \(rightSide)")
        validated = false
      }
      
      if !validated {
        AppUtil.playEffect(SoundEffect.AnswerIncorrect)
        AppUtil.log("Invalid input format")
        return
      }
      
      leftAnswer1Text.text = ""
      leftAnswer2Text.text = ""
      leftOpText.text = ""
      rightAnswer1Text.text = ""
      rightAnswer2Text.text = ""
      rightOpText.text = ""
      completeBtn.enabled = false
    }

// Obsolete code for handling isAlmostFinished for Direct
//      else {
//        checkResult()  // need to check again if it is already finished
//        
//        if !isFinished && (!(leftOpText.text == "÷" && rightOpText.text == "÷") ||
//          !(leftAnswer2Text.text == rightAnswer2Text.text) || !(leftAnswer1Text.text == leftAnswer2Text.text + "x")) {
//            AppUtil.playEffect(SoundEffect.AnswerIncorrect)
//            AppUtil.log("Invalid division parameters")
//            return
//        } else {
//          AppUtil.log("complete la")
//          AppUtil.playEffect(SoundEffect.AnswerCorrect)
//          AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)
//          
//          operand1.value = 0
//          operand2.value = 1
//          operand2.hasX = true
//          operand3.value = answer
//          operand3.hasX = false
//          operand4.value = 0
//          leftOp = ""
//          rightOp = ""
//          stepValues.append([operand1, operand2, operand3, operand4])
//          stepOps.append([leftOp, rightOp])
//          currStep++
//          currPage = currStep
//          
//          isFinished = true
//          setupScreen()
//          completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
//          completeImage.hidden = false
//          UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nextQuestionBtn)
//
//          return
//        }
//      }
    
    stepValues.append([operand1, operand2, operand3, operand4])
    stepOps.append([leftOp, rightOp])
    currStep++
    currPage = currStep

    if checkResult() {
      AppUtil.log("Complete la")
      AppUtil.playEffect(SoundEffect.AnswerCorrect)
      AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)

      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nextQuestionBtn)
    }

    setupScreen()

    if isFinished {
      completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
      completeImage.hidden = false
    }
  }
  
  // MARK: - Main
  
  func genNewQuestion() {
    var numOfX = arc4random_uniform(2) + 1    // number of x
    var numOfNum = arc4random_uniform(2) + 1  // number of numbers
    var sideOfX = arc4random_uniform(2)       // 0 - left side, 1 - right side
    var sideOfNum = arc4random_uniform(2)     // 0 - left side, 1 - right side
    
    currStep = 1
    currPage = 1
    stepValues =  [[OperandStruct]]()
    operand1 = OperandStruct(value: 0, hasX: false)
    operand2 = OperandStruct(value: 0, hasX: false)
    operand3 = OperandStruct(value: 0, hasX: false)
    operand4 = OperandStruct(value: 0, hasX: false)
    stepOps = [[String]]()
    leftOp = ""
    rightOp = ""
    
    almostFinished = false
    isFinished = false
    
    if difficultyLevel == DifficultyLevel.Easy {
      numOfX = 1
      numOfNum = 2
      sideOfX = 0
    }
    
    if difficultyLevel == DifficultyLevel.Easy || difficultyLevel == DifficultyLevel.Difficult {
      // Handle the left side
      // Create an X
      if numOfX == 2 || (numOfX == 1 && sideOfX == 0) {
        // Put in either operand1 or operand2
        if arc4random_uniform(2) == 0 {
          operand1.hasX = true
          operand1.value = Int(arc4random_uniform(algebraParam.xCoeff)) + 1
//          if arc4random_uniform(2) == 0 {
//            operand1.value *= -1
//          }
        } else {
          operand2.hasX = true
          operand2.value = Int(arc4random_uniform(algebraParam.xCoeff)) + 1
//          if arc4random_uniform(2) == 0 {
//            operand2.value *= -1
//          }
        }
      }

      // Create a number
      if numOfNum == 2 || (numOfNum == 1 && sideOfNum == 0) {
        // Put in either operand1 or operand2
        if operand1.value == 0 {
          operand1.hasX = false
          operand1.value = Int(arc4random_uniform(algebraParam.numCoeff)) + 1
          if arc4random_uniform(2) == 0 {
            operand1.value *= -1
          }
        } else if operand2.value == 0 {
          operand2.hasX = false
          operand2.value = Int(arc4random_uniform(algebraParam.numCoeff)) + 1
          if arc4random_uniform(2) == 0 {
          operand2.value *= -1
          }
        } else {
          if arc4random_uniform(2) == 0 {
            operand1.hasX = false
            operand1.value = Int(arc4random_uniform(algebraParam.numCoeff)) + 1
            if arc4random_uniform(2) == 0 {
              operand1.value *= -1
            }
          } else {
            operand2.hasX = false
            operand2.value = Int(arc4random_uniform(algebraParam.numCoeff)) + 1
            if arc4random_uniform(2) == 0 {
              operand2.value *= -1
            }
          }
        }
      }
      
      // If operand2 is empty, move operand1 to operand2
      if operand2.value == 0 {
        operand2.value = operand1.value
        operand2.hasX = operand1.hasX
        operand1.value = 0
        operand1.hasX = false
      }

      // Handle the right side
      // Create an X
      if numOfX == 2 || (numOfX == 1 && sideOfX == 1) {
        // Put in either operand3 or operand4
        if arc4random_uniform(2) == 0 {
          operand3.hasX = true
          operand3.value = Int(arc4random_uniform(algebraParam.xCoeff)) + 1
          if arc4random_uniform(2) == 0 {
            operand3.value *= -1
          }
        } else {
          operand4.hasX = true
          operand4.value = Int(arc4random_uniform(algebraParam.xCoeff)) + 1
          if arc4random_uniform(2) == 0 {
            operand4.value *= -1
          }
        }
      }
      
      // Create a number
      if numOfNum == 2 || (numOfNum == 1 && sideOfNum == 1) {
        // Put in either operand3 or operand4
        if operand3.value == 0 {
          operand3.hasX = false
          operand3.value = Int(arc4random_uniform(algebraParam.numCoeff)) + 1
          if arc4random_uniform(2) == 0 {
            operand3.value *= -1
          }
        } else if operand4.value == 0 {
          operand4.hasX = false
          operand4.value = Int(arc4random_uniform(algebraParam.numCoeff)) + 1
          if arc4random_uniform(2) == 0 {
            operand4.value *= -1
          }
        } else {
          if arc4random_uniform(2) == 0 {
            operand3.hasX = false
            operand3.value = Int(arc4random_uniform(algebraParam.numCoeff)) + 1
            if arc4random_uniform(2) == 0 {
              operand3.value *= -1
            }
          } else {
            operand4.hasX = false
            operand4.value = Int(arc4random_uniform(algebraParam.numCoeff)) + 1
            if arc4random_uniform(2) == 0 {
              operand4.value *= -1
            }
          }
        }
      }

      // If operand3 is empty, move operand4 to operand3
      if operand3.value == 0 {
        operand3.value = operand4.value
        operand3.hasX = operand4.hasX
        operand4.value = 0
        operand4.hasX = false
      }
      
      // Assign an answer for X and make the equation work
      var leftSide = 0
      if difficultyLevel == DifficultyLevel.Easy {
        answer = Int(arc4random_uniform(UInt32(algebraParam.xAnswerEasy))) + 1
      } else {
        answer = Int(arc4random_uniform(UInt32(algebraParam.xAnswerDifficult))) + 1
      }
      leftSide = Int(operand1.hasX ? operand1.value * answer : operand1.value)
      leftSide = leftSide + Int(operand2.hasX ? operand2.value * answer : operand2.value)
      leftSide = leftSide + Int(operand3.hasX ? operand3.value * answer : operand3.value) * -1
      leftSide = leftSide + Int(operand4.hasX ? operand4.value * answer : operand4.value) * -1
      
      println("Answer is \(answer), left side is \(leftSide)")
      
      if !operand1.hasX && operand1.value != 0 {
        operand1.value -= leftSide
      } else if !operand2.hasX && operand2.value != 0 {
        operand2.value -= leftSide
      } else if !operand3.hasX && operand3.value != 0 {
        operand3.value += leftSide
      } else if !operand4.hasX && operand4.value != 0 {
        operand4.value += leftSide
      }
      
      if operand1.value == 0 || operand2.value == 0 {
        leftOp = ""
      } else {
        if operand2.value > 0 {
          leftOp = "+"
        } else {
          operand2.value *= -1
          leftOp = "-"
        }
      }
    
      if operand3.value == 0 || operand4.value == 0 {
        rightOp = ""
      } else {
        if operand4.value > 0 {
          rightOp = "+"
        } else {
          operand4.value *= -1
          rightOp = "-"
        }
      }
    } else {   // custom question
      var num = Int(arc4random_uniform(UInt32(questionsBank.count)))
      var customQuestion = questionsBank[num] as! Dictionary<String, AnyObject>
      var operation: AnyObject = customQuestion["Operation"]!
      var selected: AnyObject = customQuestion["Selected"]!
      var numbers: AnyObject = customQuestion["Numbers"]!
      
      while !(selected as! Bool) {
        num = Int(arc4random_uniform(UInt32(questionsBank.count)))
        customQuestion = questionsBank[num] as! Dictionary<String, AnyObject>
        operation = customQuestion["Operation"]!
        selected = customQuestion["Selected"]!
        numbers = customQuestion["Numbers"]!
      }
      
      switch operation as! String {
      case "BALANCE":
        solveWith = SolveMethod.Balance
      case "DIRECT":
        solveWith = SolveMethod.Direct
      default:
        println("Should not happen \(operation as! String)")
      }
      
      var tmpStr = (numbers as! [String])[0]
      var sign = 1
      if tmpStr != "" {
        if tmpStr.hasSuffix("x") {
          operand1.hasX = true
          if count(tmpStr) == 1 {
            operand1.value = 1
          } else {
            tmpStr = tmpStr.substringToIndex(advance(tmpStr.startIndex, count(tmpStr) - 1))
            if tmpStr == "-" {
              operand1.value = -1
            } else if tmpStr.hasPrefix("-") {
              sign = -1
              tmpStr = tmpStr.substringFromIndex(advance(tmpStr.startIndex, 1))
            }
            operand1.value = tmpStr.toInt()! * sign
          }
        } else {
          operand1.value = tmpStr.toInt()!
        }
      }
      
      tmpStr = (numbers as! [String])[1]
      sign = 1
      if tmpStr != "" {
        if tmpStr.hasSuffix("x") {
          operand2.hasX = true
          if count(tmpStr) == 1 {
            operand2.value = 1
          } else {
            tmpStr = tmpStr.substringToIndex(advance(tmpStr.startIndex, count(tmpStr) - 1))
            if tmpStr == "-" {
              operand2.value = -1
            } else if tmpStr.hasPrefix("-") {
              sign = -1
              tmpStr = tmpStr.substringFromIndex(advance(tmpStr.startIndex, 1))
            }
            operand2.value = tmpStr.toInt()! * sign
          }
        } else {
          operand2.value = tmpStr.toInt()!
        }
      }
      
      tmpStr = (numbers as! [String])[2]
      sign = 1
      if tmpStr != "" {
        if tmpStr.hasSuffix("x") {
          operand3.hasX = true
          if count(tmpStr) == 1 {
            operand3.value = 1
          } else {
            tmpStr = tmpStr.substringToIndex(advance(tmpStr.startIndex, count(tmpStr) - 1))
            if tmpStr == "-" {
              operand3.value = -1
            } else if tmpStr.hasPrefix("-") {
              sign = -1
              tmpStr = tmpStr.substringFromIndex(advance(tmpStr.startIndex, 1))
            }
            operand3.value = tmpStr.toInt()! * sign
          }
        } else {
          operand3.value = tmpStr.toInt()!
        }
      }
      
      tmpStr = (numbers as! [String])[3]
      sign = 1
      if tmpStr != "" {
        if tmpStr.hasSuffix("x") {
          operand4.hasX = true
          if count(tmpStr) == 1 {
            operand4.value = 1
          } else {
            tmpStr = tmpStr.substringToIndex(advance(tmpStr.startIndex, count(tmpStr) - 1))
            if tmpStr == "-" {
              operand4.value = -1
            } else if tmpStr.hasPrefix("-") {
              sign = -1
              tmpStr = tmpStr.substringFromIndex(advance(tmpStr.startIndex, 1))
            }
            operand4.value = tmpStr.toInt()! * sign
          }
        } else {
          operand4.value = tmpStr.toInt()!
        }
      }

      answer = solveForX()
      println("Custom questions - \(answer)")
      
      if operand1.value == 0 || operand2.value == 0 {
        leftOp = ""
      } else {
        if operand2.value > 0 {
          leftOp = "+"
        } else {
          operand2.value *= -1
          leftOp = "-"
        }
      }
      
      if operand3.value == 0 || operand4.value == 0 {
        rightOp = ""
      } else {
        if operand4.value > 0 {
          rightOp = "+"
        } else {
          operand4.value *= -1
          rightOp = "-"
        }
      }
    }
    
    // Store question to stepValues array
    stepValues.append([operand1, operand2, operand3, operand4])
    stepOps.append([leftOp, rightOp])
    
    if solveWith == SolveMethod.Balance {
      completeBtn.enabled = false
    } else if solveWith == SolveMethod.Direct {
      completeBtn.enabled = true
    }
    
    setupScreen()
  }

  func setupScreen() {
    let userDefaults = NSUserDefaults()
    var tmpString: String
    var labelStr = ""
    var accessibilityStr = ""
    
    // Hide the complete image
    completeImage.hidden = true
    
    // Clear the existing fields
    leftOperand1.text = ""
    leftOperand2.text = ""
    rightOperand1.text = ""
    rightOperand2.text = ""
    answer1Text.text = ""
    answer2Text.text = ""
    
    leftAnswer1Text.text = ""
    leftAnswer2Text.text = ""
    leftOpText.text = ""
    rightAnswer1Text.text = ""
    rightAnswer2Text.text = ""
    rightOpText.text = ""
    
    // Need to reset the operands after each step for Direct method
    if solveWith == SolveMethod.Direct {
      operand1.value = 0
      operand1.hasX = false
      operand2.value = 0
      operand2.hasX = false
      operand3.value = 0
      operand3.hasX = false
      operand4.value = 0
      operand4.hasX = false
      leftOp = ""
      rightOp = ""
    }
    
    // Unhide fields in case they are hidden by previous step
    leftOperand1.hidden = false
    leftOperand2.hidden = false
    leftOpImage.hidden = false
    rightOperand1.hidden = false
    rightOperand2.hidden = false
    rightOpImage.hidden = false
    
    leftOperand1.enabled = false
    leftOperand2.enabled = false
    rightOperand1.enabled = false
    rightOperand2.enabled = false
    
    (labelStr, accessibilityStr) = genStepLabel(currPage - 1)
    stepLabel.text = "第 \(currPage) 步"
    stepLabel.accessibilityLabel = stepLabel.text! + accessibilityStr

    
    if solveWith == SolveMethod.Balance {
      answer1Text.setFieldStyle(FieldStyle.Active)
      answer2Text.setFieldStyle(FieldStyle.Active)
    } else {
      leftAnswer1Text.setFieldStyle(FieldStyle.Active)
      leftAnswer2Text.setFieldStyle(FieldStyle.Active)
      leftOpText.setFieldStyle(FieldStyle.Active)
      rightAnswer1Text.setFieldStyle(FieldStyle.Active)
      rightAnswer2Text.setFieldStyle(FieldStyle.Active)
      rightOpText.setFieldStyle(FieldStyle.Active)
    }

    directEqualImage.hidden = false
    
    // Handle the display of the operands
    if stepValues[currPage - 1][0].value != 0 {
      tmpString = stepValues[currPage - 1][0].hasX ? "x" : ""
      leftOperand1.text = String(stepValues[currPage - 1][0].value) + tmpString
      leftOperand1.hidden = false
    } else {
      leftOperand1.text = ""
      leftOperand1.hidden = true
    }
    leftOperand1.text = leftOperand1.text == "1x" ? "x" : leftOperand1.text
    leftOperand1.text = leftOperand1.text == "-1x" ? "-x" : leftOperand1.text
    
    if stepOps[currPage - 1][0] == "+" {
      leftOpImage.image = UIImage(named: "op-add")
      leftOpImage.accessibilityLabel = "加"
    } else if stepOps[currPage - 1][0] == "-" {
      leftOpImage.image = UIImage(named: "op-subtract")
      leftOpImage.accessibilityLabel = "減"
    } else if stepOps[currPage - 1][0] == "÷" {
      leftOpImage.image = UIImage(named: "op-divide")
      leftOpImage.accessibilityLabel = "除"
    }
    
    if stepOps[currPage - 1][0] == "" || leftOperand1.hidden == true {
      leftOpImage.hidden = true
    } else {
      leftOpImage.hidden = false
    }
    
    if stepValues[currPage - 1][1].value != 0 {
      tmpString = stepValues[currPage - 1][1].hasX ? "x" : ""
      leftOperand2.text = String(stepValues[currPage - 1][1].value) + tmpString
      leftOperand2.hidden = false
    } else {
      if solveWith == SolveMethod.Balance {
        leftOperand2.text = ""
        leftOperand2.hidden = true
        leftOpImage.hidden = true
      } else {
        leftOperand2.text = "0"
        leftOperand2.hidden = false
      }
    }

    if leftOperand1.hidden == true && leftOperand2.hidden == true {
      leftOperand2.text = "0"
      leftOperand2.hidden = false
    }
    leftOperand2.text = leftOperand2.text == "1x" ? "x" : leftOperand2.text
    leftOperand2.text = leftOperand2.text == "-1x" ? "-x" : leftOperand2.text
    
    if stepValues[currPage - 1][2].value != 0 {
      tmpString = stepValues[currPage - 1][2].hasX ? "x" : ""
      rightOperand1.text = String(stepValues[currPage - 1][2].value) + tmpString
      rightOperand1.hidden = false
    } else {
      rightOperand1.text = "0"
      rightOperand1.hidden = false
    }
    rightOperand1.text = rightOperand1.text == "1x" ? "x" : rightOperand1.text
    rightOperand1.text = rightOperand1.text == "-1x" ? "-x" : rightOperand1.text
    
    if stepValues[currPage - 1][3].value != 0 {
      tmpString = stepValues[currPage - 1][3].hasX ? "x" : ""
      rightOperand2.text = String(stepValues[currPage - 1][3].value) + tmpString
      rightOperand2.hidden = false
    } else {
      rightOperand2.text = ""
      rightOperand2.hidden = true
      rightOpImage.hidden = true
    }
    if rightOperand1.hidden == true  && rightOperand2.hidden == true {
      rightOperand1.text = "0"
      rightOperand1.hidden = false
    }
    rightOperand2.text = rightOperand2.text == "1x" ? "x" : rightOperand2.text
    rightOperand2.text = rightOperand2.text == "-1x" ? "-x" : rightOperand2.text

    if stepOps[currPage - 1][1] == "+" {
      rightOpImage.image = UIImage(named: "op-add")
      rightOpImage.accessibilityLabel = "加"
    } else if stepOps[currPage - 1][1] == "-" {
      rightOpImage.image = UIImage(named: "op-subtract")
      rightOpImage.accessibilityLabel = "減"
    } else if stepOps[currPage - 1][1] == "÷" {
      rightOpImage.image = UIImage(named: "op-divide")
      rightOpImage.accessibilityLabel = "除"
    }
    
    if stepOps[currPage - 1][1] == "" || rightOperand2.hidden == true {
      rightOpImage.hidden = true
    } else {
      rightOpImage.hidden = false
    }
    
    // Handle field attributes for the answer fields
    answer1Text.hidden = solveWith == SolveMethod.Balance ? false : true
    answer1Text.enabled = solveWith == SolveMethod.Balance ? true : false
    answer2Text.hidden = solveWith == SolveMethod.Balance ? false : true
    answer2Text.enabled = solveWith == SolveMethod.Balance ? true : false
    leftAnswer1Text.hidden = solveWith == SolveMethod.Direct ? false : true
    leftAnswer1Text.enabled = solveWith == SolveMethod.Direct ? true : false
    leftAnswer2Text.hidden = solveWith == SolveMethod.Direct ? false : true
    leftAnswer2Text.enabled = solveWith == SolveMethod.Direct ? true : false
    leftOpText.hidden = solveWith == SolveMethod.Direct ? false : true
    leftOpText.enabled = solveWith == SolveMethod.Direct ? true : false
    rightAnswer1Text.hidden = solveWith == SolveMethod.Direct ? false : true
    rightAnswer1Text.enabled = solveWith == SolveMethod.Direct ? true : false
    rightAnswer2Text.hidden = solveWith == SolveMethod.Direct ? false : true
    rightAnswer2Text.enabled = solveWith == SolveMethod.Direct ? true : false
    rightOpText.hidden = solveWith == SolveMethod.Direct ? false : true
    rightOpText.enabled = solveWith == SolveMethod.Direct ? true : false
    
    println("\(currPage) - \(currStep)")
    // Special handling for the last step
    if currPage == currStep && almostFinished {
      leftOperand2.enabled = false
      rightOperand1.enabled = false
      answer1Text.hidden = false
      answer2Text.hidden = false
      completeBtn.enabled = false
    }
    if currPage == currStep && isFinished {
      leftOperand1.hidden = true
      leftOpImage.hidden = true
      leftOperand2.enabled = false
      rightOperand1.enabled = false
      rightOpImage.hidden = true
      rightOperand2.hidden = true
      
    }
    if isFinished || currPage != currStep {
      // For balance method
      answer1Text.hidden = true
      answer2Text.hidden = true
      
      // For direct method
      leftAnswer1Text.hidden = true
      leftOpText.hidden = true
      leftAnswer2Text.hidden = true
      rightAnswer1Text.hidden = true
      rightOpText.hidden = true
      rightAnswer2Text.hidden = true
      
      directEqualImage.hidden = true
    }
    
    // Handle the display of previous steps
    var tmpStr = ""
    
    s1Label.hidden = false
    s2Label.hidden = false
    if currPage == 1 {
      s1Label.hidden = true
      s2Label.hidden = true
    } else if currPage == 2 {
      s2Label.hidden = true
    }
    
    if s1Label.hidden == false {
      tmpStr = "第\(currPage - 1)步 : "
      (labelStr, accessibilityStr) = genStepLabel(currPage - 2)
      
      s1Label.text = tmpStr + labelStr
      s1Label.accessibilityLabel = tmpStr + accessibilityStr
    }
    
    if s2Label.hidden == false {
      tmpStr = "第\(currPage - 2)步 : "
      (labelStr, accessibilityStr) = genStepLabel(currPage - 3)
      
      s2Label.text = tmpStr + labelStr
      s2Label.accessibilityLabel = tmpStr + accessibilityStr
    }

    // Set questionlabel
    (labelStr, accessibilityStr) = genStepLabel(0)
    questionLabel.accessibilityLabel = accessibilityStr
    finalAnswerStr = "答對啦, 如果"
    finalAnswerStr = finalAnswerStr + accessibilityStr + "x 就等如" + String(answer)
    AppUtil.log("---" + accessibilityStr)
    
    // Set colors
    AppUtil.setCustomColors(view)
    if userDefaults.objectForKey("displayGrid") as! Bool {
      gridImage.hidden = false
      gridImage.image = gridImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    } else {
      gridImage.hidden = true
    }
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
  }

  func checkResult() -> Bool {
    println("\(operand1.value) - \(operand2.value) - \(operand3.value) - \(operand4.value)")
    
    if (operand1.value == 0 && operand2.hasX || operand1.hasX && operand2.value == 0) &&
      (!operand3.hasX && operand4.value == 0 || !operand4.hasX && operand3.value == 0) {
        almostFinished = true
        
        if operand3.value == answer || operand4.value == answer {
          isFinished = true
          return true
        }
    } else {
      almostFinished = false
    }
    
    return false
  }
  
  func setDifficultyLevel(level: DifficultyLevel) {
    difficultyLevel = level
    
    if difficultyLevel == DifficultyLevel.Easy {
      solveWith = SolveMethod.Balance
    } else if difficultyLevel == DifficultyLevel.Difficult {
      solveWith = SolveMethod.Direct
    }
  }

  func genStepLabel(step: Int) -> (labelStr:String, accessibilityStr:String) {
    var labelStr = ""
    var accessibilityStr = ""
    
    if stepValues[step][0].value != 0 {
      if abs(stepValues[step][0].value) == 1 && stepValues[step][0].hasX {
        if stepValues[step][0].value == -1 {
          accessibilityStr = "負"
        }
      } else {
        labelStr += String(stepValues[step][0].value)
        accessibilityStr += String(stepValues[step][0].value)
      }
      if stepValues[step][0].hasX {
        labelStr += "x"
        accessibilityStr += "x"
      }
    }
    
    if stepOps[step][0] == "+" {
      labelStr += "+"
      accessibilityStr += "加"
    } else if stepOps[step][0] == "-" {
      labelStr += "-"
      accessibilityStr += "減"
    } else if stepOps[step][0] == "÷" {
      labelStr += "÷"
      accessibilityStr += "除"
    }
    
    if stepValues[step][1].value != 0 {
      if stepValues[step][1].value > 0 {
        if !(stepValues[step][1].value == 1 && stepValues[step][1].hasX) {
          labelStr += String(stepValues[step][1].value)
          accessibilityStr += String(stepValues[step][1].value)
        }
      } else {
        labelStr += "-"
        accessibilityStr += "負"
        if !(stepValues[step][1].value == -1 && stepValues[step][1].hasX) {
          labelStr += String(abs(stepValues[step][1].value))
          accessibilityStr += String(abs(stepValues[step][1].value))
        }
      }
      if stepValues[step][1].hasX {
        labelStr += "x"
        accessibilityStr += "x"
      }
    }
    
    if stepValues[step][0].value == 0 && stepValues[step][1].value == 0 {
      labelStr += "0"
      accessibilityStr += "0"
    }
    
    labelStr += "="
    accessibilityStr += "等如"
    if stepValues[step][2].value != 0 {
      if abs(stepValues[step][2].value) == 1 && stepValues[step][2].hasX {
        if stepValues[step][2].value == -1 {
          accessibilityStr = "負"
        }
      } else {
        labelStr += String(stepValues[step][2].value)
        accessibilityStr += String(stepValues[step][2].value)
      }
      if stepValues[step][2].hasX {
        labelStr += "x"
        accessibilityStr += "x"
      }
    }

    if stepOps[step][1] == "+" {
      labelStr += "+"
      accessibilityStr += "加"
    } else if stepOps[step][1] == "-" {
      labelStr += "-"
      accessibilityStr += "減"
    } else if stepOps[step][1] == "÷" {
      labelStr += "÷"
      accessibilityStr += "除"
    }
    
    if stepValues[step][3].value != 0 {
      if stepValues[step][3].value > 0 {
        if !(stepValues[step][3].value == 1 && stepValues[step][3].hasX) {
          labelStr += String(stepValues[step][3].value)
          accessibilityStr += String(stepValues[step][3].value)
        }
      } else {
        labelStr += "-"
        accessibilityStr += "負"
        if !(stepValues[step][3].value == -1 && stepValues[step][3].hasX) {
          labelStr += String(abs(stepValues[step][3].value))
          accessibilityStr += String(abs(stepValues[step][3].value))
        }
      }
      if stepValues[step][3].hasX {
        labelStr += "x"
        accessibilityStr += "x"
      }
    }

    if stepValues[step][2].value == 0 && stepValues[step][3].value == 0 {
      labelStr += "0"
      accessibilityStr += "0"
    }

    AppUtil.log("label : \(labelStr)")
    AppUtil.log("accessibility : \(accessibilityStr)")
    
    return (labelStr, accessibilityStr)
  }
  
  func solveForX() -> Int {
    var totalX = 0
    var total = 0
    
    if operand1.hasX {
      totalX += operand1.value
    } else {
      total += operand1.value * -1
    }
    if operand2.hasX {
      totalX += operand2.value
    } else {
      total += operand2.value * -1
    }
    if operand3.hasX {
      totalX += operand3.value * -1
    } else {
      total += operand3.value
    }
    if operand4.hasX {
      totalX += operand4.value * -1
    } else {
      total += operand4.value
    }
    
    if totalX != 0 {
      answer = total / totalX
    } else {
      answer = -1
    }
    
    if answer < 0 {   // invalid answer
      answer = -1
    }
    return answer
  }
  
  // MARK: Gestures
  
  override func accessibilityPerformEscape() -> Bool {
    backBtnClicked(0)
    
    return true
  }
  
  override func accessibilityPerformMagicTap() -> Bool {
    completeBtnClicked(0)
    
    return true
  }
  
  override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
    switch direction{
    case .Right:
      goPrevPage()
    case .Left:
      goNextPage()
    default:
      AppUtil.log("direction not handled")
    }
    
    return true
  }
  
  func goPrevPage() {
    if currPage > 1 {
      currPage--
      setupScreen()
      
      UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "跳到第\(currPage)版, 第\(currPage)及第\(currPage+1)步")
    } else {
      // This is the first page, notify user
      UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "在最前一版")
    }
  }
  
  func goNextPage() {
    if currPage < currStep {
      currPage++
      setupScreen()
      
      UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "跳到第\(currPage)版, 第\(currPage)及第\(currPage+1)步")
    } else {
      // This is the last page, notify user
      UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "在最後一版")
    }
  }
  
  // MARK: - Text editing
  
  
  func textFieldDidBeginEditing(textField: UITextField) {
    // Store value in case the user cancel
    currField = textField.tag
    currFieldText = textField.text
    textField.text = ""
    
    enterSign = ""
    enterValue = ""
    enterX = ""
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, textField.inputView?.viewWithTag(0))
    
    // Keep the user in the keyboard view
    view.isAccessibilityElement = true
  }

  func textFieldDidEndEditing(textField: UITextField) {
    // Update operands if the field has been changed
    if textField.text != currFieldText {
      updateOperands()
    }
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, textField)
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
      // In Direct method, only allow in the 4 answer boxes
      if solveWith == SolveMethod.Direct {
        if !(currField >= 21 && currField <= 24) {
          return
        }

        // Append only if field contains less than 2 digits
        if (count(enterValue) == 3)  ||
          (count(enterValue) == 1 && enterValue == "0") {
            return
        }
      }
      
      if solveWith == SolveMethod.Balance {
        // Append only if field contains less than 2 digits
        if (count(enterValue) == 3)  ||
          (count(enterValue) == 0 && keyReceived.rawValue == 0) {
            return
        }
      }
      
      enterValue += String(keyReceived.rawValue)
      
      tmpTextField.text = enterSign + enterValue + enterX
//      switch enterSign {
//      case "+":
//        tmpTextField.accessibilityLabel = "加" + enterValue + enterX
//      case "-":
//        tmpTextField.accessibilityLabel = "減" + enterValue + enterX
//      case "÷":
//        tmpTextField.accessibilityLabel = "除" + enterValue + enterX
//      default:
//        tmpTextField.accessibilityLabel = enterValue + enterX
//      }
      AppUtil.sayIt(tmpTextField.accessibilityLabel)
      
      // Keep the VO focus on the original key
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .Sign:
      // Does not allow in Balance method
      if solveWith == SolveMethod.Balance {
        return
      }
      
      // In Direct method, only allow in the 4 answer boxes
      if !(currField >= 21 && currField <= 24) {
        return
      }
      
      if enterSign == "" {
        enterSign = "-"
      } else {
        enterSign = ""
      }

      tmpTextField.text = enterSign + enterValue + enterX
      AppUtil.sayIt(tmpTextField.accessibilityLabel)
      
      // Keep the VO focus on the original key
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .Add:
      if solveWith == SolveMethod.Balance {
        enterSign = "+"
        tmpTextField.text = enterSign + enterValue + enterX
        AppUtil.sayIt(tmpTextField.accessibilityLabel)
      } else {
        // Only allow in the 2 operator fields
        if !(currField == 31 || currField == 32) {
          return
        }
        
        enterSign = "+"
        tmpTextField.text = "+"
      }
      
      // Keep the VO focus on the original key
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .Subtract:
      if solveWith == SolveMethod.Balance {
        enterSign = "-"
        tmpTextField.text = enterSign + enterValue + enterX
        AppUtil.sayIt(tmpTextField.accessibilityLabel)
      } else {
        // Only allow in the 2 operator fields
        if !(currField == 31 || currField == 32) {
          return
        }

        enterSign = "-"
        tmpTextField.text = "-"
      }
      
      // Keep the VO focus on the original key
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .Divide:
      if solveWith == SolveMethod.Balance {
        enterSign = "÷"
        tmpTextField.text = enterSign + enterValue + enterX
        AppUtil.sayIt(tmpTextField.accessibilityLabel)
      } else {
        // Only allow in the 2 operator fields
        if !(currField == 31 || currField == 32) {
          return
        }

        enterSign = "÷"
        tmpTextField.text = "÷"
      }
      
      // Keep the VO focus on the original key
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .X:
      // In Direct method, only allow in the 4 answer boxes
      if solveWith == SolveMethod.Direct {
        if !(currField >= 21 && currField <= 24) {
          return
        }
        
        // Cannot enter X if have already entered a zero
        if count(enterValue) == 1 && enterValue == "0" {
          return
        }
      }

      enterX = "x"
      if enterValue == "" {
        enterValue == "1"
      }
      
      tmpTextField.text = enterSign + enterValue + enterX
      switch enterSign {
      case "+":
        tmpTextField.accessibilityLabel = "加" + enterValue + enterX
      case "-":
        tmpTextField.accessibilityLabel = "減" + enterValue + enterX
      case "/":
        tmpTextField.accessibilityLabel = "除" + enterValue + enterX
      default:
        break
      }
      AppUtil.sayIt(tmpTextField.accessibilityLabel)
      
      // Keep the VO focus on the original key
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .Delete:
      if solveWith == SolveMethod.Balance  ||
        solveWith == SolveMethod.Direct && (currField >= 21 && currField <= 24) {
        
        // If have "x", then delete the "x" first
        if enterX == "x" {
          enterX = ""
        } else {
          switch count(enterValue) {
          case 1:
            enterValue = ""
          case 2:
            enterValue = String(enterValue[enterValue.startIndex])
          case 3:
            enterValue = String(enterValue[enterValue.startIndex]) + String(enterValue[advance(enterValue.startIndex, 1)])
          default:
            break
          }
        }
          
        tmpTextField.text = enterSign + enterValue + enterX
      } else {
        tmpTextField.text = ""
      }
      AppUtil.sayIt(tmpTextField.text)
      
      // Keep the VO focus on the original key
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .Cancel:
      tmpTextField.text = currFieldText
      tmpTextField.resignFirstResponder()
      if solveWith == SolveMethod.Balance && tmpTextField.text == "" {
        completeBtn.enabled = false
      } else {
        completeBtn.enabled = true
      }
      view.isAccessibilityElement = false
    case .Confirm:
      tmpTextField.resignFirstResponder()
      if solveWith == SolveMethod.Balance && tmpTextField.text == "" {
        completeBtn.enabled = false
      } else {
        completeBtn.enabled = true
      }
      view.isAccessibilityElement = false
    default:
      break
    }
  }
  
  // This function needs to be triggered in different places
  func updateOperands() {
    var trueValue = 0
    var trueHasX = false
    
    if enterX == "x" {
      trueHasX = true
    }
    if enterValue == "" {
      if trueHasX {
        enterValue = "1"
        trueValue = 1
      } else {
        enterValue = "0"
        trueValue = 0
      }
    } else {
      trueValue = enterValue.toInt()!
    }
    
    if enterSign == "-" {
      trueValue *= -1
    }
    if trueValue == 0 {
      trueHasX = false
    }
    
    switch currField {
    case 21:
      operand1.value = trueValue
      operand1.hasX = trueHasX
    case 22:
      operand2.value = trueValue
      operand2.hasX = trueHasX
    case 23:
      operand3.value = trueValue
      operand3.hasX = trueHasX
    case 24:
      operand4.value = trueValue
      operand4.hasX = trueHasX
    case 31:
      leftOp = enterSign
    case 32:
      rightOp = enterSign
    default:
      break
    }
  }
}

