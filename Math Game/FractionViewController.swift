//
//  FractionViewController.swift
//  Math Game
//
//  Created by Richard on 16/9/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class FractionViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var leftView: UIView!
  @IBOutlet weak var leftStepLabel: UILabel!
  @IBOutlet weak var left1NumText: UITextField!
  @IBOutlet weak var left1DenText: UITextField!
  @IBOutlet weak var left2NumText: UITextField!
  @IBOutlet weak var left2DenText: UITextField!
  @IBOutlet weak var leftOpImage: UIImageView!
  @IBOutlet weak var left1LineImage: UIImageView!
  @IBOutlet weak var left2LineImage: UIImageView!
  
  @IBOutlet weak var rightView: UIView!
  @IBOutlet weak var rightStepLabel: UILabel!
  @IBOutlet weak var right1NumText: UITextField!
  @IBOutlet weak var right1DenText: UITextField!
  @IBOutlet weak var right2NumText: UITextField!
  @IBOutlet weak var right2DenText: UITextField!
  @IBOutlet weak var rightOpImage: UIImageView!
  @IBOutlet weak var right1LineImage: UIImageView!
  @IBOutlet weak var right2LineImage: UIImageView!
  
  @IBOutlet weak var equalImage: UIImageView!
  @IBOutlet weak var completeImage: UIImageView!
  @IBOutlet weak var gridImage: UIImageView!
  @IBOutlet weak var gridView: UIView!
  @IBOutlet weak var completeBtn: UIButton!
  @IBOutlet weak var nextQuestionBtn: UIButton!
  
  
  var currPage = 1        // which page is being shown
  var currStep = 5        // working on which step
  var currField = 0       // tag of field that is being edited
  var currFieldText = ""  // value of current field
  var currOp = OpType.Add // what operation
  
  var startTag = 51
  
  var stepValues: [[Int]] = [[0]]

  var difficultyLevel = DifficultyLevel.Easy
  var holdObj = RetainObj()

  var questionsBank = []
  var answer = 0.0
  var isAnswerInteger = false
  var finished = false
  var finalAnswerStr = ""
  
  let fractionParam = FractionParam()
  
  var doAdd = true
  var doSubtract = true
  var doMultiply = true
  var doDivide = true
  
  var displaySingleFraction = false
  
  
  // MARK: View
  
  override func viewDidLoad() {
    let userDefaults = NSUserDefaults()
    super.viewDidLoad()
    
    // Initialize first and second steps
    stepValues += [[0, 0, 0, 0]]
    stepValues += [[0, 0, 0, 0]]
    
    // Set VO field sequence
    leftView.accessibilityElements = [leftStepLabel, left1NumText, left1LineImage, left1DenText, leftOpImage, left2NumText, left2LineImage, left2DenText, equalImage]
    rightView.accessibilityElements = [rightStepLabel, right1NumText, right1LineImage, right1DenText, rightOpImage, right2NumText, right2LineImage, right2DenText]

    // Setup accessibility labels that will not be changed
    left1NumText.accessibilityLabel = "第一份子"
    left1DenText.accessibilityLabel = "第一份母"
    left2NumText.accessibilityLabel = "第二份子"
    left2DenText.accessibilityLabel = "第二份母"
    right1NumText.accessibilityLabel = "第一份子"
    right1DenText.accessibilityLabel = "第一份母"
    right2NumText.accessibilityLabel = "第二份子"
    right2DenText.accessibilityLabel = "第二份母"

    // Fields in left view are never editable
    left1NumText.enabled = false
    left1DenText.enabled = false
    left2NumText.enabled = false
    left2DenText.enabled = false
    
    // Assign inputView to fields in right view
    right1NumText.inputView = AppUtil.createKeyboardView(holdObj)
    right1DenText.inputView = AppUtil.createKeyboardView(holdObj)
    right2NumText.inputView = AppUtil.createKeyboardView(holdObj)
    right2DenText.inputView = AppUtil.createKeyboardView(holdObj)

    // Handle initial display
    leftView.backgroundColor = UIColor.clearColor()
    rightView.backgroundColor = UIColor.clearColor()

    // Read in the question bank
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0) as! NSString
    let filePath = documentsDirectory.stringByAppendingPathComponent("FractionQuestions.plist")
    
    questionsBank = NSArray(contentsOfFile: filePath)!
    AppUtil.log("There are \(questionsBank.count) questions for fraction")
  
    // See what operations are allowed
    doAdd = userDefaults.objectForKey("fractionAdd") as! Bool
    doSubtract = userDefaults.objectForKey("fractionSubtract") as! Bool
    doMultiply = userDefaults.objectForKey("fractionMultiply") as! Bool
    doDivide = userDefaults.objectForKey("fractionDivide") as! Bool
    
    // In case no operation is allowed, then do Addition
    if !doAdd && !doSubtract && !doMultiply && !doDivide {
      doAdd = true
    }
    
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
    let question = genNewQuestion()
    
    stepValues = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
    stepValues[1] = [question.fNum, question.fDen, question.sNum, question.sDen]
    stepValues[2] = [0, 0, 0, 0]
    currOp = question.op
    
    currStep = 2
    currPage = 1
    
    finished = false
    
    setupScreen()
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, questionLabel)
  }
  
  @IBAction func redoBtnClicked(sender: AnyObject) {
    let tmp = stepValues[1]
    
    stepValues = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
    stepValues[1] = tmp
    stepValues[2] = [0, 0, 0, 0]
    
    currStep = 2
    currPage = 1
    
    displaySingleFraction = false
    completeBtn.enabled = true
    finished = false
    
    setupScreen()
  }
  
  @IBAction func prevPageBtnClicked(sender: AnyObject) {
    goPrevPage()
  }
  
  
  @IBAction func nextPageBtnClicked(sender: AnyObject) {
    goNextPage()
  }
  
  @IBAction func completeBtnClicked(sender: AnyObject) {
    // Check validity of operands
    if !checkResult() {
      AppUtil.playEffect(SoundEffect.AnswerIncorrect)
      return
    }
    
    if finished {
      AppUtil.log("Complete la")
      AppUtil.playEffect(SoundEffect.AnswerCorrect)
      if isAnswerInteger {
        AppUtil.sayIt("答對啦" + finalAnswerStr + right1NumText.text, withDelay: 3.0)
      } else {
        AppUtil.sayIt("答對啦" + finalAnswerStr + right1DenText.text + "份之" + right1NumText.text, withDelay: 3.0)
      }
      
      completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
      completeImage.hidden = false
      completeBtn.enabled = false
      
      right1NumText.enabled = false
      right1NumText.setFieldStyle(FieldStyle.Inactive)
      right1DenText.enabled = false
      right1DenText.setFieldStyle(FieldStyle.Inactive)
      right2NumText.enabled = false
      right2NumText.setFieldStyle(FieldStyle.Inactive)
      right2DenText.enabled = false
      right2DenText.setFieldStyle(FieldStyle.Inactive)

      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nextQuestionBtn)

      return
    }
    
    // If left operand is empty, move right operand to left operand
    if stepValues[currStep][0] == 0 && stepValues[currStep][1] == 0 {
      stepValues[currStep][0] = stepValues[currStep][2]
      stepValues[currStep][1] = stepValues[currStep][3]
      stepValues[currStep][2] = 0
      stepValues[currStep][3] = 0
    }
    
    currStep++
    currPage++
    stepValues += [[0, 0, 0, 0]]
    
    setupScreen()
    AppUtil.sayIt(Voices.gotoNextStep)
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, right1NumText)
  }
  
  // MARK: - Main
  
  func genNewQuestion() -> (fNum:Int, fDen:Int, sNum:Int, sDen:Int, op:OpType) {
    var fNum: Int = 1
    var fDen: Int = 1
    var sNum: Int = 1
    var sDen: Int = 1
    var op: OpType = OpType.Add
    
    displaySingleFraction = false
    completeBtn.enabled = true
    isAnswerInteger = false
    
    var num: UInt32 = 0
    do {   // keep on looking for an operation that is allowed
      num = arc4random_uniform(4)  // 0..3 for +-*/
    } while !(num == 0 && doAdd) && !(num == 1 && doSubtract) && !(num == 2 && doMultiply) && !(num == 3 && doDivide)
    
    switch num {
    case 0:
      op = OpType.Add
    case 1:
      op = OpType.Subtract
    case 2:
      op = OpType.Multiply
    case 3:
      op = OpType.Divide
    default:
      break
    }

    if difficultyLevel == DifficultyLevel.Easy || difficultyLevel == DifficultyLevel.Difficult {
      // Generate random question
      var upperLimit: UInt32
      if difficultyLevel == DifficultyLevel.Easy {   // easy, single digits only
        upperLimit = fractionParam.easyLimit
      } else {
        upperLimit = fractionParam.difficultLimit
      }
      do {
        fNum = Int(arc4random_uniform(upperLimit - 2)) + 1
        fDen = Int(arc4random_uniform(upperLimit - UInt32(fNum))) + 1 + fNum
        sNum = Int(arc4random_uniform(upperLimit - 2)) + 1
        sDen = Int(arc4random_uniform(upperLimit - UInt32(sNum))) + 1 + sNum
      } while (op == OpType.Subtract && Double(fNum)/Double(fDen) <= Double(sNum)/Double(sDen)) ||
              (difficultyLevel == DifficultyLevel.Difficult && fDen * sDen > 100 && !(fDen % sDen == 0) && !(sDen % fDen == 0)) ||
              (difficultyLevel == DifficultyLevel.Difficult && op == OpType.Divide && !(fDen % sNum == 0) && !(sNum % fDen == 0))

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
      case "ADD":
        op = OpType.Add
      case "SUBTRACT":
        op = OpType.Subtract
      case "MULTIPLY":
        op = OpType.Multiply
      case "DIVIDE":
        op = OpType.Divide
      default:
        AppUtil.log("Should not happen")
      }
      fNum = (numbers as! [Int])[0]
      fDen = (numbers as! [Int])[1]
      sNum = (numbers as! [Int])[2]
      sDen = (numbers as! [Int])[3]
    }
    
    // Calculate the expected answer
    var fraction1 = Double(fNum) / Double(fDen)
    var fraction2 = Double(sNum) / Double(sDen)
    switch op {
    case .Add:
      answer = fraction1 + fraction2
    case .Subtract:
      answer = fraction1 - fraction2
    case .Multiply:
      answer = fraction1 * fraction2
    case .Divide:
      answer = fraction1 / fraction2
    }
    AppUtil.log("\(fraction1) - \(fraction2) - \(answer) - \(Int(round(answer)))")
    if abs(answer - Double(Int(round(answer)))) < 0.01 {
      isAnswerInteger = true
    }
    AppUtil.log("Expected answer is \(answer) - \(isAnswerInteger)")

    return(fNum, fDen, sNum, sDen, op)
  }
  
  func setupScreen() {
    let userDefaults = NSUserDefaults()
    
    // Hide the complete image
    completeImage.hidden = true
    
    // Show all fields in case they are hidden
    left1NumText.hidden = false
    left1LineImage.hidden = false
    left1DenText.hidden = false
    left2NumText.hidden = false
    left2LineImage.hidden = false
    left2DenText.hidden = false
    leftOpImage.hidden = false
    leftOpImage.isAccessibilityElement = true
    right1NumText.hidden = false
    right1LineImage.hidden = false
    right1DenText.hidden = false
    right2NumText.hidden = false
    right2LineImage.hidden = false
    right2DenText.hidden = false
    rightOpImage.hidden = false
    rightOpImage.isAccessibilityElement = true
    
    // Setup left view
    leftStepLabel.text = "第 \(currPage) 步"
    left1NumText.text = stepValues[currPage][0] == 0 ? "" : String(stepValues[currPage][0])
    left1DenText.text = stepValues[currPage][1] == 0 ? "" : String(stepValues[currPage][1])
    left2NumText.text = stepValues[currPage][2] == 0 ? "" : String(stepValues[currPage][2])
    left2DenText.text = stepValues[currPage][3] == 0 ? "" : String(stepValues[currPage][3])
    
    // Setup right view
    rightStepLabel.text = "第 \(currPage + 1) 步"
    right1NumText.text = stepValues[currPage + 1][0] == 0 ? "" : String(stepValues[currPage + 1][0])
    right1DenText.text = stepValues[currPage + 1][1] == 0 ? "" : String(stepValues[currPage + 1][1])
    right2NumText.text = stepValues[currPage + 1][2] == 0 ? "" : String(stepValues[currPage + 1][2])
    right2DenText.text = stepValues[currPage + 1][3] == 0 ? "" : String(stepValues[currPage + 1][3])
    
    // Enable or disable fields in right view depending on which page we are on
    if currPage < currStep - 1 {
      // Not on last page
      right1NumText.enabled = false
      right1NumText.setFieldStyle(FieldStyle.Inactive)
      right1DenText.enabled = false
      right1DenText.setFieldStyle(FieldStyle.Inactive)
      right2NumText.enabled = false
      right2NumText.setFieldStyle(FieldStyle.Inactive)
      right2DenText.enabled = false
      right2DenText.setFieldStyle(FieldStyle.Inactive)
      
      completeBtn.enabled = false
    } else {   // last page
      // On the last page
      right1NumText.enabled = true
      right1NumText.setFieldStyle(FieldStyle.Active)
      right1DenText.enabled = true
      right1DenText.setFieldStyle(FieldStyle.Active)
      right2NumText.enabled = true
      right2NumText.setFieldStyle(FieldStyle.Active)
      right2DenText.enabled = true
      right2DenText.setFieldStyle(FieldStyle.Active)
      
      completeBtn.enabled = true
    }
    
    // Display the correct operator image
    switch currOp {
    case OpType.Add:
      leftOpImage.image = UIImage(named: "op-add")
      rightOpImage.image = UIImage(named: "op-add")
    case OpType.Subtract:
      leftOpImage.image = UIImage(named: "op-subtract")
      rightOpImage.image = UIImage(named: "op-subtract")
    case OpType.Multiply:
      leftOpImage.image = UIImage(named: "op-multiply")
      rightOpImage.image = UIImage(named: "op-multiply")
    case OpType.Divide:
      if currPage == 1 {
        leftOpImage.image = UIImage(named: "op-divide")
      } else {
        leftOpImage.image = UIImage(named: "op-multiply")
      }
      rightOpImage.image = UIImage(named: "op-multiply")
    default:
      leftOpImage.image = UIImage(named: "op-add")
      rightOpImage.image = UIImage(named: "op-add")
    }

    // Setup accessibility labels
    switch currOp {
    case OpType.Add:
      leftOpImage.accessibilityLabel = "加"
      rightOpImage.accessibilityLabel = "加"
    case OpType.Subtract:
      leftOpImage.accessibilityLabel = "減"
      rightOpImage.accessibilityLabel = "減"
    case OpType.Multiply:
      leftOpImage.accessibilityLabel = "乘"
      rightOpImage.accessibilityLabel = "乘"
    case OpType.Divide:
      leftOpImage.accessibilityLabel = "除"
      rightOpImage.accessibilityLabel = "乘"
    }
    questionLabel.accessibilityLabel = "\(stepValues[1][1])份之\(stepValues[1][0])" + leftOpImage.accessibilityLabel + "\(stepValues[1][3])份之\(stepValues[1][2])等如幾多?"
    finalAnswerStr = "\(stepValues[1][1])份之\(stepValues[1][0])" + leftOpImage.accessibilityLabel + "\(stepValues[1][3])份之\(stepValues[1][2])等如"
  
    // Special consideration when one of the operands may be empty
    // Left view
    if left2NumText.text == "" && left2DenText.text == "" {   // 2nd operand is empty
      left2NumText.text = left1NumText.text
      left2DenText.text = left1DenText.text
      left2NumText.accessibilityLabel = "份子"
      left2DenText.accessibilityLabel = "份母"
      left1NumText.hidden = true
      left1DenText.hidden = true
      left1LineImage.hidden = true
      leftOpImage.hidden = true
      leftOpImage.isAccessibilityElement = false   // very strange, just hiding is not enough, need to do this
    } else {
      left2NumText.accessibilityLabel = "第二份子"
      left2DenText.accessibilityLabel = "第二份母"
      left1NumText.hidden = false
      left1DenText.hidden = false
      left1LineImage.hidden = false
      leftOpImage.hidden = false
    }
    
    // Right view
    if currPage < currStep - 1 {
      if right2NumText.text == "" && right2DenText.text == "" {   // 2nd operand is empty
        right1NumText.accessibilityLabel = "份子"
        right1DenText.accessibilityLabel = "份母"
        right2NumText.hidden = true
        right2DenText.hidden = true
        right2LineImage.hidden = true
        rightOpImage.hidden = true
        rightOpImage.isAccessibilityElement = false   // very strange, just hiding is not enough, need to do this
      } else {
        right1NumText.accessibilityLabel = "第一份子"
        right1DenText.accessibilityLabel = "第一份母"
        right2NumText.hidden = false
        right2DenText.hidden = false
        right2LineImage.hidden = false
        rightOpImage.hidden = false
      }
    } else {
      // If the left has only 1 operand or the fractions can no longer be factored or the denominator for both left operand are the same, then the right should also has 1 operand
      if left1NumText.hidden == true || displaySingleFraction ||
        (left1DenText.text == left2DenText.text && (currOp == OpType.Add || currOp == OpType.Subtract))
      {
        right2NumText.hidden = true
        right2DenText.hidden = true
        right2LineImage.hidden = true
        rightOpImage.hidden = true
        
        if isAnswerInteger {
          // Expect to enter the answer
          stepValues[currStep][1] = 1
          right1DenText.text = "1"
          right1DenText.hidden = true
          right1LineImage.hidden = true
          right1NumText.accessibilityLabel = "答案"
        } else {
          right1DenText.hidden = false
          right1LineImage.hidden = false
          right1NumText.accessibilityLabel = "第一份子"
        }
      } else {
        right2NumText.hidden = false
        right2DenText.hidden = false
        right2LineImage.hidden = false
        rightOpImage.hidden = false
      }
    }
    
    // Set colors
    AppUtil.setCustomColors(view)
    AppUtil.setCustomColors(leftView)
    AppUtil.setCustomColors(rightView)
    
    leftView.backgroundColor = UIColor.clearColor()
    rightView.backgroundColor = UIColor.clearColor()
    if userDefaults.objectForKey("displayGrid") as! Bool {
      gridImage.hidden = false
      gridImage.image = gridImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    } else {
      gridImage.hidden = true
    }
  }

  func checkResult() -> Bool {
    var fraction1: Double = 0.0
    var fraction2: Double = 0.0
    var stepAnswer: Double = 0.0
    var has1: Bool = true
    var has2: Bool = true
    
    // Num and Den cannot have one null and one not null
    if (right1NumText.text == "" && right1DenText.text != "") ||
      (right1NumText.text != "" && right1DenText.text == "") ||
      (right2NumText.text == "" && right2DenText.text != "") ||
      (right2NumText.text != "" && right2DenText.text == "") {
        AppUtil.log("\(right1NumText.text) - \(right1DenText.text) - \(right2NumText.text) - \(right2DenText.text)")
        return false
    }
    
    if right1NumText.text == "" && right1DenText.text == "" {
      has1 = false
    }
    
    if right2NumText.text == "" && right2DenText.text == "" {
      has2 = false
    }
    
    // Cannot be both all null
    if !has1 && !has2 {
      return false
    }
    
    // Den cannot be zero
    if has1 && right1DenText.text.toInt()! == 0 {
      return false
    }
    if has2 && right2DenText.text.toInt()! == 0 {
      return false
    }
    
    if has1 {
      fraction1 = Double(right1NumText.text.toInt()!) / Double(right1DenText.text.toInt()!)
    }
    
    if has2 {
      fraction2 = Double(right2NumText.text.toInt()!) / Double(right2DenText.text.toInt()!)
    }
    
    if has1 && has2 {
      switch currOp {
      case .Add:
        stepAnswer = fraction1 + fraction2
      case .Subtract:
        stepAnswer = fraction1 - fraction2
      case .Multiply:
        stepAnswer = fraction1 * fraction2
      case .Divide:
        stepAnswer = fraction1 * fraction2
      }
    } else if has1 {
      stepAnswer = fraction1
    } else {
      stepAnswer = fraction2
    }
    
    AppUtil.log("Answer for this step is \(stepAnswer)")
    
    // Check if need to go to displaySingleFraction mode before returning
    if !displaySingleFraction {   // only need to check if not already displaying single fraction
      if currOp == .Multiply || currOp == .Divide {   // display single fraction if can not be
        if (has1 && !has2) && greatestCommonDenominator(right1NumText.text.toInt()!, b: right1DenText.text.toInt()!) == 1 {
          displaySingleFraction = true
        } else if (!has1 && has2) && greatestCommonDenominator(right2NumText.text.toInt()!, b: right2DenText.text.toInt()!) == 1 {
          displaySingleFraction = true
        } else if (has1 && has2)
          && greatestCommonDenominator(right1NumText.text.toInt()!, b: right1DenText.text.toInt()!) == 1
          && greatestCommonDenominator(right2NumText.text.toInt()!, b: right2DenText.text.toInt()!) == 1
          && greatestCommonDenominator(right1NumText.text.toInt()!, b: right2DenText.text.toInt()!) == 1
          && greatestCommonDenominator(right2NumText.text.toInt()!, b: right1DenText.text.toInt()!) == 1 {
            displaySingleFraction = true
        }
      } else {   // if both denominators are the same, then should show a single fraction
        if (has1 && has2) && right1DenText.text.toInt()! == right2DenText.text.toInt()! {
          displaySingleFraction = true
        }
      }
    }

//    if Int(stepAnswer * 10000) == Int(answer * 10000) {
    if abs(stepAnswer - answer) < 0.01 {  // experimenting with different ways to determine if answer is correct, as! can have rounding error
      if !(has1 && has2) {   // either operand must be empty
        if has1 {
          AppUtil.log("\(right1NumText.text.toInt()!) over \(right1DenText.text.toInt()!), factor is \(greatestCommonDenominator(right1NumText.text.toInt()!, b: right1DenText.text.toInt()!))")
          
          if greatestCommonDenominator(right1NumText.text.toInt()!, b: right1DenText.text.toInt()!) == 1 {
            finished = true
          }
        } else {
          AppUtil.log("\(right2NumText.text.toInt()!) over \(right2DenText.text.toInt()!), factor is \(greatestCommonDenominator(right2NumText.text.toInt()!, b: right2DenText.text.toInt()!))")
          
          if greatestCommonDenominator(right2NumText.text.toInt()!, b: right2DenText.text.toInt()!) == 1 {
            finished = true
          }
        }
      }
      return true
    } else {
      return false
    }
  }
  
  func setDifficultyLevel(level: DifficultyLevel) {
    difficultyLevel = level
  }
  
  func greatestCommonDenominator(a: Int, b: Int) -> Int {
    return b == 0 ? a : greatestCommonDenominator(b, b: a % b)
  }
  
  // MARK: - Gestures
  
  override func accessibilityPerformEscape() -> Bool {
    backBtnClicked(0)
    
    return true
  }
  
  override func accessibilityPerformMagicTap() -> Bool {
    completeBtnClicked(0)
    
    return true
  }
  
  override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
    // No need to check for orientation in this case
    //    let theAppDelegate = UIApplication.sharedApplication()
    //    let orientation = theAppDelegate.statusBarOrientation
    
    switch direction {
    case .Right:
      goPrevPage()
    case .Left:
      goNextPage()
    default:
      break
    }
    
    return true
  }
  
  func goPrevPage() {
    if currPage > 1 {
      currPage--
      setupScreen()
      
      AppUtil.sayIt("跳到第\(currPage)版, 第\(currPage)及第\(currPage+1)步")
    } else {
      AppUtil.sayIt("在最前一版, 總共有\(currStep-1)版")
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, leftStepLabel)
  }
  
  func goNextPage() {
    if currPage < currStep - 1 {
      currPage++
      setupScreen()

      AppUtil.sayIt("跳到第\(currPage)版, 第\(currPage)及第\(currPage+1)步")
    } else {
      AppUtil.sayIt("在最後一版, 總共有\(currStep-1)版")
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, leftStepLabel)
  }
  
  // MARK: Text editing
  
  // Track which field is being edited
  func textFieldDidBeginEditing(textField: UITextField) {
    currField = textField.tag
    
    // Store value in case the user cancel
    currFieldText = textField.text
    textField.text = ""
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, textField.inputView?.viewWithTag(0))
    
    // Keep the user in the keyboard view
    view.isAccessibilityElement = true
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    if let newValue = textField.text.toInt() {
      stepValues[currStep][currField - startTag] = newValue
    } else {
      stepValues[currStep][currField - startTag] = 0
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
      // Append only if field contains less than 2 digits
      if count(tmpTextField.text.utf16) < 3 {   // allow 3 digit number
        tmpTextField.text = tmpTextField.text + String(keyReceived.rawValue)
        AppUtil.sayIt(tmpTextField.text)
      } else {
        AppUtil.sayIt(Voices.fieldIsFull)
      }
      
      // Keep the VO focus on the original key
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tmpTextField.inputView?.viewWithTag(keyReceived.rawValue))
    case .Delete:
        tmpTextField.text = tmpTextField.text.substringToIndex(advance(tmpTextField.text.startIndex, count(tmpTextField.text)-1))
    case .Cancel:
      tmpTextField.text = currFieldText
      tmpTextField.resignFirstResponder()
      view.isAccessibilityElement = false
    case .Confirm:
      if let newValue = tmpTextField.text.toInt() {
        stepValues[currStep][currField - startTag] = newValue
      } else {
        stepValues[currStep][currField - startTag] = 0
      }
      tmpTextField.resignFirstResponder()
      view.isAccessibilityElement = false
    default:
      break
    }
  }
}
