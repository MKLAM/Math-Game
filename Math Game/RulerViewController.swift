//
//  RulerViewController.swift
//  Math Game
//
//  Created by Richard on 10/7/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit
import AudioToolbox

class RulerButton: UIButton {
  override func accessibilityElementDidBecomeFocused() {
    let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "sound-1", "mp3", nil)
    var mySound: SystemSoundID = 0
    AudioServicesCreateSystemSoundID(soundURL, &mySound)
    AudioServicesPlaySystemSound(mySound)
    
    NSNotificationCenter.defaultCenter().postNotificationName("buttonFocused", object:nil, userInfo:["tag":"\(self.tag)"])
    self.layer.borderColor = UIColor.redColor().CGColor
    self.layer.borderWidth = 4
    
    AppUtil.log("\(self.tag)")
  }
  
  override func accessibilityElementDidLoseFocus() {
    NSNotificationCenter.defaultCenter().postNotificationName("buttonLostFocus", object:nil, userInfo:["tag":"\(self.tag)"])
    self.layer.borderColor = UIColor.blackColor().CGColor
    self.layer.borderWidth = 1
  }
}

class RulerViewController: UIViewController {
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var valueLabel: UILabel!

  @IBOutlet weak var horizontalRulerView: UIView!
  @IBOutlet weak var verticalRulerView: UIView!
  
  @IBOutlet weak var completeImage: UIImageView!
  @IBOutlet weak var gridView: UIView!
  @IBOutlet weak var gridImage: UIImageView!
  
  @IBOutlet weak var nextQuestionBtn: UIButton!
  
  var horizontalRulerBtnStartTag = 1
  var verticalRulerBtnStartTag = 51
  var startTag = 0
  var currPage = 3
  var totalPages = 5
  var numSpan = 0
  var firstNum = 0
  
  var solveWith = RulerType.Direct
  var operand1: Int = 0
  var operand2: Int = 0
  var operand3: Int = 0
  var answer = 0
  var difficultyLevel = DifficultyLevel.Easy

  var finalAnswerStr = ""
  
  var questionsBank = []
  var orientation = RulerOrientation.Vertical
  
  var fgColor = UIColor.blackColor()
  
  let rulerParam = RulerParam()
  
  // MARK: - View
  
  override func viewDidLoad() {
    var userDefaults = NSUserDefaults()
    
    super.viewDidLoad()
    
    // Read in the question bank
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0) as! NSString
    let filePath = documentsDirectory.stringByAppendingPathComponent("RulerQuestions.plist")
    
    questionsBank = NSArray(contentsOfFile: filePath)!
    AppUtil.log("There are \(questionsBank.count) questions for ruler")
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "buttonFocused:", name: "buttonFocused", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "buttonLostFocus:", name: "buttonLostFocus", object: nil)
    
    let orientationIndex = userDefaults.objectForKey("rulerOrientation") as! Int
    if orientationIndex == 0 {
      orientation = RulerOrientation.Vertical
    } else {
      orientation = RulerOrientation.Horizontal
    }
    if orientation == RulerOrientation.Horizontal {
// Uncomment the following if the horizontal page is displaying 21 buttons
//      currPage = 3
//      totalPages = 5
//      numSpan = 20
//      firstNum = -50
      currPage = 5
      totalPages = 9
      numSpan = 10
      firstNum = -45
      startTag = horizontalRulerBtnStartTag
      verticalRulerView.hidden = true
    } else {
      currPage = 5
      totalPages = 9
      numSpan = 10
      firstNum = -45
      startTag = verticalRulerBtnStartTag
      horizontalRulerView.hidden = true
    }
    
    fgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as! UIColor!
  }
  
  override func viewDidAppear(animated: Bool) {
    let userDefaults = NSUserDefaults()
    
    nextQuestionBtnClicked(0)
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, questionLabel)
    
    AppUtil.setCustomColors(view)
    horizontalRulerView.backgroundColor = UIColor.clearColor()
    verticalRulerView.backgroundColor = UIColor.clearColor()
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
  
  @IBAction func prevPageBtnClicked(sender: AnyObject) {
    if orientation == RulerOrientation.Horizontal {
      goNextPage()
    } else {
      goPrevPage()
    }
  }
  
  @IBAction func nextPageBtnClicked(sender: AnyObject) {
    if orientation == RulerOrientation.Horizontal {
      goPrevPage()
    } else {
      goNextPage()
    }
  }
  
  @IBAction func rulerBtnClicked(sender: AnyObject) {
    // This is to show the number when VO is off
    NSNotificationCenter.defaultCenter().postNotificationName("buttonFocused", object:nil, userInfo:["tag":"\(sender.tag)"])

    let value = firstNum + (currPage-1) * numSpan + (sender.tag - startTag)
    
    if value == answer {
      AppUtil.log("Complete la")
      AppUtil.playEffect(SoundEffect.AnswerCorrect)
      AppUtil.sayIt(finalAnswerStr, withDelay: 3.0)
      completeImage.image = completeImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
      completeImage.hidden = false
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nextQuestionBtn)
    } else {
      AppUtil.log("Incorrect answer")
      AppUtil.playEffect(SoundEffect.AnswerIncorrect)
    }
  }
  
  // MARK: - Main
  
  func genNewQuestion() {
    var op: OpType
    var answerType = 0   // 0 - min, 1 - middle, 2 - max
    
    operand1 = 0
    operand2 = 0
    operand3 = 0
    answer = 0
    if orientation == RulerOrientation.Horizontal {
      currPage = 5  // 3 if horizontal page is displaying 21 buttons
    } else {
      currPage = 5
    }
    
    if difficultyLevel == DifficultyLevel.Easy || difficultyLevel == DifficultyLevel.Difficult {
      if solveWith == RulerType.Direct {
        do {
          operand1 = Int(arc4random_uniform(rulerParam.numMax))
          operand2 = Int(arc4random_uniform(rulerParam.numMax))
          if Int(arc4random_uniform(2)) == 0 {
            operand1 *= -1
          }
          if Int(arc4random_uniform(2)) == 0 {
            operand2 *= -1
          }
          if Int(arc4random_uniform(2)) == 0 {
            op = .Subtract
            answer = operand1 - operand2
          } else {
            op = .Add
            answer = operand1 + operand2
          }
        } while answer < -45 || answer > 45
        if op == OpType.Subtract {
          questionLabel.text = "(\(operand1)) - (\(operand2)) = ?"
        } else {
          questionLabel.text = "(\(operand1)) + (\(operand2)) = ?"
        }
        
        questionLabel.text = ""
        questionLabel.accessibilityLabel = ""
        questionLabel.text = String(operand1)
        if operand1 < 0 {
          questionLabel.accessibilityLabel = "負"
        }
        if op == OpType.Subtract {
          questionLabel.text = questionLabel.text! + " - "
          questionLabel.accessibilityLabel = questionLabel.accessibilityLabel + "\(abs(operand1))減"
        } else {
          questionLabel.text = questionLabel.text! + " + "
          questionLabel.accessibilityLabel = questionLabel.accessibilityLabel + "\(abs(operand1))加"
        }
        if operand2 < 0 {
          questionLabel.text = questionLabel.text! + "(\(operand2))"
          questionLabel.accessibilityLabel = questionLabel.accessibilityLabel + "負"
        } else {
          questionLabel.text = questionLabel.text! + "\(operand2)"
        }
        finalAnswerStr = "答對啦"
        finalAnswerStr = finalAnswerStr + questionLabel.accessibilityLabel + "\(abs(operand2))等如" + String(answer)
        questionLabel.accessibilityLabel = questionLabel.accessibilityLabel + "\(abs(operand2))等如幾多?"
        questionLabel.text = questionLabel.text! + " = ?"
      } else if solveWith == RulerType.Compare {
        operand1 = Int(arc4random_uniform(79)) + 1 - 45    // generate the min number from -45 to 35
        println("Op1 = \(operand1)")
        operand3 = Int(arc4random_uniform(UInt32(45 - operand1 - 5))) + 3 + operand1   // generate the max number from operand1 to 50
        operand2 = Int(arc4random_uniform(UInt32(operand3 - operand1 - 1))) + 1 + operand1   // generate the mid number
        
        println("\(operand1), \(operand2), \(operand3)")
        
        answerType = Int(arc4random_uniform(3))
        
        // Randomize the display
        var tmpArr = [operand1, operand2, operand3]
        for var i=1; i<10; i++ {
          var op1 = Int(arc4random_uniform(3))
          var op2 = Int(arc4random_uniform(3))
          var tmpVar: Int
          
          tmpVar = tmpArr[op1]
          tmpArr[op1] = tmpArr[op2]
          tmpArr[op2] = tmpVar
        }
        
        finalAnswerStr = "答對啦"
        switch answerType {
        case 0:
          questionLabel.text = "請找出最小數字 \(tmpArr[0])  \(tmpArr[1])  \(tmpArr[2])"
          questionLabel.accessibilityLabel = "請找出最小數字 \(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2]))"
          answer = operand1
          finalAnswerStr = finalAnswerStr + "\(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2])) 最小數字係" + String(answer)
        case 1:
          questionLabel.text = "請找出中間數字 \(tmpArr[0])  \(tmpArr[1])  \(tmpArr[2])"
          questionLabel.accessibilityLabel = "請找出中間數字 \(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2]))"
          answer = operand2
          finalAnswerStr = finalAnswerStr + "\(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2])) 中間數字係" + String(answer)
        case 2:
          questionLabel.text = "請找出最大數字 \(tmpArr[0])  \(tmpArr[1])  \(tmpArr[2])"
          questionLabel.accessibilityLabel = "請找出最大數字 \(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2]))"
          answer = operand3
          finalAnswerStr = finalAnswerStr + "\(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2])) 最大數字係" + String(answer)
        default:
          break
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
      
      if (operation as! String) == "COMPARE-BIG" || (operation as! String) == "COMPARE-MIDDLE" || (operation as! String) == "COMPARE-SMALL" {
        solveWith = RulerType.Compare
        
        operand1 = (numbers as! [Int])[0]
        operand2 = (numbers as! [Int])[1]
        operand3 = (numbers as! [Int])[2]
 
        // Randomize the display
        var tmpArr = [operand1, operand2, operand3]
        for var i=1; i<10; i++ {
          var op1 = Int(arc4random_uniform(3))
          var op2 = Int(arc4random_uniform(3))
          var tmpVar: Int
          
          tmpVar = tmpArr[op1]
          tmpArr[op1] = tmpArr[op2]
          tmpArr[op2] = tmpVar
        }

        switch operation as! String {
        case "COMPARE-BIG":
          questionLabel.text = "請找出最大數字 \(tmpArr[0])  \(tmpArr[1])  \(tmpArr[2])"
          questionLabel.accessibilityLabel = "請找出最大數字 \(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2]))"
          answer = operand3
        case "COMPARE-MIDDLE":
          questionLabel.text = "請找出中間數字 \(tmpArr[0])  \(tmpArr[1])  \(tmpArr[2])"
          questionLabel.accessibilityLabel = "請找出中間數字 \(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2]))"
          answer = operand2
        case "COMPARE-SMALL":
          questionLabel.text = "請找出最小數字 \(tmpArr[0])  \(tmpArr[1])  \(tmpArr[2])"
          questionLabel.accessibilityLabel = "請找出最小數字 \(numberToVOString(tmpArr[0]))  \(numberToVOString(tmpArr[1]))  \(numberToVOString(tmpArr[2]))"
          answer = operand1
        default:
          break
        }
        
        AppUtil.log("\(operand1), \(operand2), \(operand3)")
      } else {
        solveWith = RulerType.Direct
        
        questionLabel.text = operation as? String
        questionLabel.accessibilityLabel = operation as? String
        answer = (numbers as! [Int])[0]
        AppUtil.log("\(answer)")
      }
    }
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
    
    setupScreen()
  }
  
  func setupScreen() {
    var userDefaults = NSUserDefaults()
    var fgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor

    // Hide the complete image
    completeImage.hidden = true

    // Reset the valueLabel
    valueLabel.text = ""
    
    // Fix the button labels
    var tmpBtn = UIButton()
    
    for var i=1; i<=numSpan+1; i++ {
      tmpBtn = self.view.viewWithTag(startTag + (i-1)) as! UIButton
      tmpBtn.setTitle(String(firstNum + (currPage-1) * numSpan + (i - 1)), forState: UIControlState.Normal)
      tmpBtn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
      if orientation == RulerOrientation.Horizontal {
        tmpBtn.titleLabel?.font = UIFont.boldSystemFontOfSize(38.0)
      } else {
        tmpBtn.titleLabel?.font = UIFont.boldSystemFontOfSize(22.0)
      }
//      tmpBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
      tmpBtn.accessibilityLabel = String(firstNum + (currPage-1) * numSpan + (i - 1))
      if solveWith == RulerType.Compare {
        let currValue = firstNum + (currPage-1) * numSpan + (i - 1)
        if currValue == operand1 || currValue == operand2 || currValue == operand3 {
          tmpBtn.accessibilityLabel = "係吾係" + tmpBtn.accessibilityLabel
          tmpBtn.layer.borderWidth = 3
          tmpBtn.layer.borderColor = UIColor.redColor().CGColor
        } else {
          tmpBtn.layer.borderWidth = 1
          tmpBtn.layer.borderColor = UIColor.blackColor().CGColor
        }
      } else {
        tmpBtn.layer.borderWidth = 1
        tmpBtn.layer.borderColor = UIColor.blackColor().CGColor
      }
    }
  }

  func setDifficultyLevel(level: DifficultyLevel) {
    difficultyLevel = level
    
    if difficultyLevel == DifficultyLevel.Easy {
      solveWith = RulerType.Direct
    } else if difficultyLevel == DifficultyLevel.Difficult {
      solveWith = RulerType.Compare
    }
  }

  // Handle the magnified label
  func buttonFocused(notification: NSNotification) {
    let userInfo: Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
    let buttonTag = userInfo["tag"]
    let value = firstNum + (currPage-1) * numSpan + (buttonTag!.toInt()! - startTag)
    
    valueLabel.text = String(value)
  }
  
  func buttonLostFocus(notification: NSNotification) {
    valueLabel.text = ""
  }
  
  func numberToVOString(inNumber: Int) -> String {
    var outString = ""
    
    if inNumber >= 0 {
      outString = String(inNumber)
    } else {
      outString = "負" + String(inNumber * -1)
    }
    return outString
  }
  
  // MARK: - Gestures

  override func accessibilityPerformEscape() -> Bool {
    backBtnClicked(0)
    
    return true
  }

  override func accessibilityScroll(direction: UIAccessibilityScrollDirection) -> Bool {
    switch direction{
    case .Right:
      AppUtil.log("right")
      if orientation == RulerOrientation.Horizontal {
        goNextPage()
      }
    case .Left:
      AppUtil.log("left")
      if orientation == RulerOrientation.Horizontal {
        goPrevPage()
      }
    case .Up:
      AppUtil.log("up")
      if orientation == RulerOrientation.Vertical {
        goPrevPage()
      }
    case .Down:
      AppUtil.log("down")
      if orientation == RulerOrientation.Vertical {
        goNextPage()
      }
    default:
      break
    }
    
    return true
  }
  
  func goPrevPage() {
    if currPage < totalPages {
      currPage++
      if valueLabel.text != "" {
        valueLabel.text = String(valueLabel.text!.toInt()! + numSpan)
      }

      setupScreen()
      
      UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "數尺由\(firstNum + (currPage-1) * numSpan)至\(firstNum + currPage * numSpan)")
    } else {
      UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "在最後一版")
    }
  }
  
  func goNextPage() {
    if currPage > 1 {
      currPage--
      if valueLabel.text != "" {
        valueLabel.text = String(valueLabel.text!.toInt()! - numSpan)
      }
      
      setupScreen()
      
      UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "數尺由\(firstNum + (currPage-1) * numSpan)至\(firstNum + currPage * numSpan)")
    } else {
      UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "在最前一版")
    }
  }
}
