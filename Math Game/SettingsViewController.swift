//
//  SettingsViewController.swift
//  Math Game
//
//  Created by Richard on 3/10/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {

  @IBOutlet weak var questionsTable: UITableView!
  @IBOutlet weak var fractionView: UIView!
  @IBOutlet weak var fraction1NumText: UITextField!
  @IBOutlet weak var fraction1DenText: UITextField!
  @IBOutlet weak var fraction2NumText: UITextField!
  @IBOutlet weak var fraction2DenText: UITextField!
  @IBOutlet weak var fractionOpSegment: UISegmentedControl!

  @IBOutlet weak var longCalcView: UIView!
  @IBOutlet weak var longCalc1NumText: UITextField!
  @IBOutlet weak var longCalc2NumText: UITextField!
  @IBOutlet weak var longCalcOpSegment: UISegmentedControl!
  
  @IBOutlet weak var algebraView: UIView!
  @IBOutlet weak var algebra1NumText: UITextField!
  @IBOutlet weak var algebra2NumText: UITextField!
  @IBOutlet weak var algebra3NumText: UITextField!
  @IBOutlet weak var algebra4NumText: UITextField!
  @IBOutlet weak var algebraMethodSegment: UISegmentedControl!
  
  @IBOutlet weak var rulerView: UIView!
  @IBOutlet weak var rulerMethodSegment: UISegmentedControl!
  @IBOutlet weak var rulerQuestionText: UITextField!
  @IBOutlet weak var rulerAnswerText: UITextField!
  @IBOutlet weak var ruler1NumText: UITextField!
  @IBOutlet weak var ruler2NumText: UITextField!
  @IBOutlet weak var ruler3NumText: UITextField!
  @IBOutlet weak var rulerNumSegment: UISegmentedControl!
  
  @IBOutlet weak var operatorView: UIView!
  @IBOutlet weak var addSwitch: UISwitch!
  @IBOutlet weak var subtractSwitch: UISwitch!
  @IBOutlet weak var multiplySwitch: UISwitch!
  @IBOutlet weak var divideSwitch: UISwitch!
  
  @IBOutlet weak var rulerOrientationLabel: UILabel!
  @IBOutlet weak var rulerOrientationSegment: UISegmentedControl!
  
  @IBOutlet weak var titleLabel: UILabel!
  
  var gameType = ""
  var questionsBank:NSMutableArray = []
  var filePath = ""
  
  // MARK: - View
  
  override func viewDidLoad() {
    var userDefaults = NSUserDefaults()
    
    super.viewDidLoad()

    // Read in the custom questions depending on game type
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0) as! NSString
    switch gameType {
    case "fraction":
      filePath = documentsDirectory.stringByAppendingPathComponent("FractionQuestions.plist")
      questionsBank = NSMutableArray(contentsOfFile: filePath)!
      titleLabel.text = "分數運算設定"
    case "longCalc":
      filePath = documentsDirectory.stringByAppendingPathComponent("LongCalcQuestions.plist")
      questionsBank = NSMutableArray(contentsOfFile: filePath)!
      titleLabel.text = "直式設定"
    case "ruler":
      filePath = documentsDirectory.stringByAppendingPathComponent("RulerQuestions.plist")
      questionsBank = NSMutableArray(contentsOfFile: filePath)!
      titleLabel.text = "數尺設定"
    case "algebra":
      filePath = documentsDirectory.stringByAppendingPathComponent("AlgebraQuestions.plist")
      questionsBank = NSMutableArray(contentsOfFile: filePath)!
      titleLabel.text = "方程式設定"
    default:
      break
    }
    
    AppUtil.log("There are \(questionsBank.count) questions")
    
    // Show/Hide views depending on game type
    fractionView.hidden = true
    fractionView.accessibilityElementsHidden = true
    longCalcView.hidden = true
    longCalcView.accessibilityElementsHidden = true
    algebraView.hidden = true
    algebraView.accessibilityElementsHidden = true
    rulerView.hidden = true
    rulerView.accessibilityElementsHidden = true
    operatorView.hidden = true
    
    rulerOrientationLabel.hidden = true
    rulerOrientationSegment.hidden = true
    
    switch gameType {
    case "fraction":
      fractionView.hidden = false
      fractionView.accessibilityElementsHidden = false
      fractionView.accessibilityElements = [fraction1NumText, fraction1DenText, fractionOpSegment, fraction2NumText, fraction2DenText]
      operatorView.hidden = false
      addSwitch.on = userDefaults.valueForKey("fractionAdd") as! Bool
      subtractSwitch.on = userDefaults.valueForKey("fractionSubtract") as! Bool
      multiplySwitch.on = userDefaults.valueForKey("fractionMultiply") as! Bool
      divideSwitch.on = userDefaults.valueForKey("fractionDivide") as! Bool
    case "longCalc":
      longCalcView.hidden = false
      longCalcView.accessibilityElementsHidden = false
      operatorView.hidden = false
      addSwitch.on = userDefaults.valueForKey("longCalcAdd") as! Bool
      subtractSwitch.on = userDefaults.valueForKey("longCalcSubtract") as! Bool
      multiplySwitch.on = userDefaults.valueForKey("longCalcMultiply") as! Bool
      divideSwitch.on = userDefaults.valueForKey("longCalcDivide") as! Bool
    case "algebra":
      algebraView.hidden = false
      algebraView.accessibilityElementsHidden = false
    case "ruler":
      rulerView.hidden = false
      rulerView.accessibilityElementsHidden = false
      
      rulerMethodSegment.selectedSegmentIndex = 0
      rulerQuestionText.hidden = false
      rulerAnswerText.hidden = false
      ruler1NumText.hidden = true
      ruler2NumText.hidden = true
      ruler3NumText.hidden = true
      rulerNumSegment.hidden = true
      
      rulerOrientationLabel.hidden = false
      rulerOrientationSegment.hidden = false
      rulerOrientationSegment.selectedSegmentIndex = userDefaults.valueForKey("rulerOrientation") as! Int
    default:
      break
    }
  }
  
//  override func shouldAutorotate() -> Bool {
//    return true
//  }
//  
//  override func supportedInterfaceOrientations() -> Int {
//    return Int(UIInterfaceOrientationMask.Portrait.rawValue) + Int(UIInterfaceOrientationMask.PortraitUpsideDown.rawValue)
//  }
  
  // MARK: - Screen buttons

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    questionsTable.scrollToRowAtIndexPath(NSIndexPath(forRow: questionsBank.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    
    UILabel.appearance().textColor = UIColor.blackColor()
    UITextField.appearance().textColor = UIColor.blackColor()
  }
  
  override func viewWillDisappear(animated: Bool) {
    var userDefaults = NSUserDefaults()
    var fgColor = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaults.objectForKey("fgColor") as! NSData) as? UIColor

    super.viewWillDisappear(animated)
    UILabel.appearance().textColor = fgColor
    UITextField.appearance().textColor = fgColor
  }
  
  @IBAction func operatorSwitch(sender: AnyObject) {
    var userDefaults = NSUserDefaults()
    var tmpSwitch = view.viewWithTag(sender.tag!) as! UISwitch
    
    switch tmpSwitch.tag {
    case 81:
      if gameType == "fraction" {
        userDefaults.setValue(tmpSwitch.on, forKey: "fractionAdd")
      } else {
        userDefaults.setValue(tmpSwitch.on, forKey: "longCalcAdd")
      }
    case 82:
      if gameType == "fraction" {
        userDefaults.setValue(tmpSwitch.on, forKey: "fractionSubtract")
      } else {
        userDefaults.setValue(tmpSwitch.on, forKey: "longCalcSubtract")
      }
    case 83:
      if gameType == "fraction" {
        userDefaults.setValue(tmpSwitch.on, forKey: "fractionMultiply")
      } else {
        userDefaults.setValue(tmpSwitch.on, forKey: "longCalcMultiply")
      }
    case 84:
      if gameType == "fraction" {
        userDefaults.setValue(tmpSwitch.on, forKey: "fractionDivide")
      } else {
        userDefaults.setValue(tmpSwitch.on, forKey: "longCalcDivide")
      }
    default:
      break
    }
  }
  
  @IBAction func rulerMethodSegmentClicked(sender: AnyObject) {
    if rulerMethodSegment.selectedSegmentIndex == 0 {
      rulerQuestionText.hidden = false
      rulerAnswerText.hidden = false
      ruler1NumText.hidden = true
      ruler2NumText.hidden = true
      ruler3NumText.hidden = true
      rulerNumSegment.hidden = true
    } else {
      rulerQuestionText.hidden = true
      rulerAnswerText.hidden = true
      ruler1NumText.hidden = false
      ruler2NumText.hidden = false
      ruler3NumText.hidden = false
      rulerNumSegment.hidden = false
    }
  }
  
  @IBAction func rulerOrientationSegmentClicked(sender: AnyObject) {
    var userDefaults = NSUserDefaults()

    userDefaults.setValue(rulerOrientationSegment.selectedSegmentIndex, forKey: "rulerOrientation")
  }
  
  @IBAction func backBtnClicked(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func addQuestionBtnClicked(sender: AnyObject) {
    var question:Dictionary<String, AnyObject> = [:]
    var msg = ""
    
    question["Selected"] = true
    
    switch gameType {
    case "fraction":
      // Check if the numbers entered are ok
      msg = checkFractionNumbers()
      if msg != "" {
        var alert = UIAlertController(title: "注意", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "關閉", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        return
      } else {
        switch fractionOpSegment.selectedSegmentIndex {
        case 0:
          question["Operation"] = "ADD"
        case 1:
          question["Operation"] = "SUBTRACT"
        case 2:
          question["Operation"] = "MULTIPLY"
        case 3:
          question["Operation"] = "DIVIDE"
        default:
          break
        }
        
        question["Numbers"] = [fraction1NumText.text.toInt()!, fraction1DenText.text.toInt()!, fraction2NumText.text.toInt()!, fraction2DenText.text.toInt()!]
      }
    case "longCalc":
      // Check if the numbers entered are ok
      msg = checkLongCalcNumbers()
      if msg != "" {
        var alert = UIAlertController(title: "注意", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "關閉", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        return
      } else {
        switch longCalcOpSegment.selectedSegmentIndex {
        case 0:
          question["Operation"] = "ADD"
        case 1:
          question["Operation"] = "SUBTRACT"
        case 2:
          question["Operation"] = "MULTIPLY"
        case 3:
          question["Operation"] = "DIVIDE"
        default:
          break
        }
        
        question["Numbers"] = [longCalc1NumText.text.toInt()!, longCalc2NumText.text.toInt()!]
      }
    case "ruler":
      // Check if the numbers entered are ok
      msg = checkRulerNumbers()
      if msg != "" {
        var alert = UIAlertController(title: "注意", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "關閉", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        return
      } else {
        if rulerMethodSegment.selectedSegmentIndex == 0 {
          question["Operation"] = rulerQuestionText.text
          question["Numbers"] = [rulerAnswerText.text.toInt()!]
        } else {
          switch rulerNumSegment.selectedSegmentIndex {
          case 0:
            question["Operation"] = "COMPARE-BIG"
          case 1:
            question["Operation"] = "COMPARE-MIDDLE"
          case 2:
            question["Operation"] = "COMPARE-SMALL"
          default:
            break
          }
          question["Numbers"] = [ruler1NumText.text.toInt()!, ruler2NumText.text.toInt()!, ruler3NumText.text.toInt()!]
        }
      }
    case "algebra":
      // Check if the numbers entered are ok
      msg = checkAlgebraNumbers()
      if msg != "" {
        var alert = UIAlertController(title: "注意", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "關閉", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        return
      } else {
        switch algebraMethodSegment.selectedSegmentIndex {
        case 0:
          question["Operation"] = "BALANCE"
        case 1:
          question["Operation"] = "DIRECT"
        default:
          println("This should not happen")
        }
        
        question["Numbers"] = [algebra1NumText.text, algebra2NumText.text, algebra3NumText.text, algebra4NumText.text]
      }
    default:
      break
    }

    [questionsBank .addObject(question)]
    saveQuestions()
    
    questionsTable.reloadData()
    // Scroll to bottom to show newly added question
    // Only works if cell is of default height.  If height is changed, e.g. with a bigger font size, this will not work
    questionsTable.scrollToRowAtIndexPath(NSIndexPath(forRow: questionsBank.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
  }
  
  @IBAction func exportBtnClicked(sender: AnyObject) {
    var emailTitle = "滙出題目"
    var messageBody = "滙出題目"
    var toRecipents = ["richard.wt.chui@gmail.com"]
    var plistData: NSData = NSData(contentsOfFile: filePath)!
    var mc: MFMailComposeViewController = MFMailComposeViewController()
    var filename = ""
    
    switch gameType {
    case "fraction":
      filename = "fraction.ebem"
      messageBody += " - 分數運算"
    case "longCalc":
      filename = "longCalc.ebem"
      messageBody += " - 直式"
    case "ruler":
      filename = "ruler.ebem"
      messageBody += " - 數尺"
    case "algebra":
      filename = "algebra.ebem"
      messageBody += " - 代數"
    default:
      break
    }
    
    mc.mailComposeDelegate = self
    mc.setSubject(emailTitle)
    mc.setMessageBody(messageBody, isHTML: false)
    mc.setToRecipients(toRecipents)
    mc.addAttachmentData(plistData, mimeType: "application/math", fileName: filename)
    
    self.presentViewController(mc, animated: true, completion: nil)
  }
  
  func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError) {
    switch result.value {
    case MFMailComposeResultCancelled.value:
      AppUtil.log("Mail cancelled")
    case MFMailComposeResultSaved.value:
      AppUtil.log("Mail saved")
    case MFMailComposeResultSent.value:
      AppUtil.log("Mail sent")
    case MFMailComposeResultFailed.value:
      AppUtil.log("Mail sent failure: \(error.localizedDescription)")
    default:
      break
    }
    self.dismissViewControllerAnimated(false, completion: nil)
  }
  
  // MARK: - Main
  
  func initGameType(type: String) {
      gameType = type
  }
  
  func saveQuestions() {
    // Save the custom questions depending on game type
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0) as! NSString
    
    switch gameType {
    case "fraction":
      let filePath = documentsDirectory.stringByAppendingPathComponent("FractionQuestions.plist")
      questionsBank.writeToFile(filePath, atomically: true)
      QuestionCount.fraction = questionsBank.count
    case "longCalc":
      let filePath = documentsDirectory.stringByAppendingPathComponent("LongCalcQuestions.plist")
      questionsBank.writeToFile(filePath, atomically: true)
      QuestionCount.longCalc = questionsBank.count
    case "ruler":
      let filePath = documentsDirectory.stringByAppendingPathComponent("RulerQuestions.plist")
      questionsBank.writeToFile(filePath, atomically: true)
      QuestionCount.ruler = questionsBank.count
    case "algebra":
      let filePath = documentsDirectory.stringByAppendingPathComponent("AlgebraQuestions.plist")
      questionsBank.writeToFile(filePath, atomically: true)
      QuestionCount.algebra = questionsBank.count
    default:
      break
    }

  }
  
  func checkFractionNumbers() -> String {
    // All numbers must exist and within range
    let num1  = fraction1NumText.text.toInt()
    let num2  = fraction1DenText.text.toInt()
    let num3  = fraction2NumText.text.toInt()
    let num4  = fraction2DenText.text.toInt()
    var op = OpType.Add
    var msg = ""
    
    switch fractionOpSegment.selectedSegmentIndex {
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

    // All boxes must be filled with a number
    if num1 != nil {
      if num1 <= 0 || num1 >= 50 {
        msg = "每個方格必須填寫一個大於0, 小於50的數字"
      }
    } else {
      msg = "每個方格必須填寫一個大於0, 小於50的數字"
    }

    if num2 != nil {
      if num2 <= 0 || num2 >= 50  {
        msg = "每個方格必須填寫一個大於0, 小於50的數字"
      }
    } else {
      msg = "每個方格必須填寫一個大於0, 小於50的數字"
    }
    
    if num3 != nil {
      if num3 <= 0 || num3 >= 50  {
        msg = "每個方格必須填寫一個大於0, 小於50的數字"
      }
    } else {
      msg = "每個方格必須填寫一個大於0, 小於50的數字"
    }
    
    if num4 != nil {
      if num4 <= 0 || num4 >= 50  {
        msg = "每個方格必須填寫一個大於0, 小於50的數字"
      }
    } else {
      msg = "每個方格必須填寫一個大於0, 小於50的數字"
    }
    
    // If subtraction, fraction 2 must be greater than fraction 1
    if op == OpType.Subtract {
      if Double(num1!) / Double(num2!) <= Double(num3!) / Double(num4!) {
        println("\(num1! / num2!) - \(num3! / num4!)")
        msg = "答案必須大於0"
      }
    }
    
    return msg
  }
  
  func checkLongCalcNumbers() -> String {
    // All numbers must exist and within range
    let num1 = longCalc1NumText.text.toInt()
    let num2 = longCalc2NumText.text.toInt()
    var op = OpType.Add
    var msg = ""
    
    switch longCalcOpSegment.selectedSegmentIndex {
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
    
    if num1 != nil {
      if num1 <= 0 {
        msg = "每個方格必須填寫一個大於0的數字"
      }
      if num1 >= 1000 {
        msg = "數字必須小於1000"
      }
    } else {
      msg = "每個方格必須填寫一個大於0的數字"
    }
    
    if num2 != nil  {
      if num2 <= 0 {
        msg = "每個方格必須填寫一個大於0的數字"
      }
      if num2 >= 1000 {
        msg = "數字必須小於1000"
      }
    } else {
      msg = "每個方格必須填寫一個大於0的數字"
    }

    if op == OpType.Subtract {
      if num1 <= num2 {
        msg = "答案必須大於0"
      }
    }
    
    if op == OpType.Multiply {
      if num1!*num2! >= 100000 {
        msg = "答案太大了"
      }
    }
    
    if op == OpType.Divide {
      if num2 > num1 {
        msg = "答案必須大於1"
      }
      if num2 >= 100 {
        msg = "除數必須小於100"
      }
    }
    
    return msg
  }
  
  func checkRulerNumbers() -> String {
    var msg = ""

    if rulerMethodSegment.selectedSegmentIndex == 0 {
      if rulerQuestionText.text == "" || rulerAnswerText.text == "" {
        msg = "必須填寫問題和答案"
      }
      
      let num  = rulerAnswerText.text.toInt()
      if num < -50 || num > 50 {
        msg = "數字必須大於-50, 小於50"
      }
    } else {
      let num1 = ruler1NumText.text.toInt()
      let num2 = ruler2NumText.text.toInt()
      let num3 = ruler3NumText.text.toInt()
      
      if (num1 < -50 || num1 > 50) || (num2 < -50 || num2 > 50) || (num3 < -50 || num3 > 50) {
        msg = "數字必須大於-50, 小於50"
      }
      
      if (num1 == num2) || (num1 == num3) || (num2 == num3) {
        msg = "所有數字必須不同"
      }
    }
    
    return msg
  }
  
  func checkAlgebraNumbers() -> String {
    var msg = ""
    
    if algebra1NumText.text == "" && algebra2NumText.text == "" {
      msg == "左方不能留空"
    }
    
    if algebra3NumText.text == "" && algebra4NumText.text == "" {
      msg == "右方不能留空"
    }
    
    if !algebra1NumText.text.hasSuffix("x") && !algebra2NumText.text.hasSuffix("x") && !algebra3NumText.text.hasSuffix("x") && !algebra4NumText.text.hasSuffix("x") {
      msg = "變數不存在"
    }
    
    return msg
  }
  
  // MARK: - Tableview handling
  
  func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
    return questionsBank.count;
  }
  
  func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    var op = ""
    var opAccessibilityString = ""
    var cellAccessibilityString = ""
    var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
    }
    cell!.textLabel!.font = UIFont.systemFontOfSize(18.0)
    
    let row = indexPath.row
    var customQuestion = questionsBank[row] as! Dictionary<String, AnyObject>
    var operation: AnyObject = customQuestion["Operation"]!
    var selected: AnyObject = customQuestion["Selected"]!
    var numbers: AnyObject = customQuestion["Numbers"]!
    
    switch operation as! String {
    case "ADD":
      op = "+"
      opAccessibilityString = "加"
    case "SUBTRACT":
      op = "-"
      opAccessibilityString = "減"
    case "MULTIPLY":
      op = "x"
      opAccessibilityString = "乘"
    case "DIVIDE":
      op = "÷"
      opAccessibilityString = "除"
    case "BALANCE":
      op = "天秤"
    case "DIRECT":
      op = "直接"
    case "COMPARE-BIG":
      op = "最大"
    case "COMPARE-MIDDLE":
      op = "中間"
    case "COMPARE-SMALL":
      op = "最小"
    default:
      op = "what?"
      AppUtil.log("What operation")
    }
    
    switch gameType {
    case "fraction":
      cell!.textLabel!.text = "\((numbers as! [Int])[0])/\((numbers as! [Int])[1]) \(op) \((numbers as! [Int])[2])/\((numbers as! [Int])[3])"
      cellAccessibilityString = "\((numbers as! [Int])[1])" + "份之" + "\((numbers as! [Int])[0])"
      cellAccessibilityString = cellAccessibilityString + opAccessibilityString + "\((numbers as! [Int])[3])" + "份之" + "\((numbers as! [Int])[2])"
    case "longCalc":
      cell!.textLabel!.text = "\((numbers as! [Int])[0]) \(op) \((numbers as! [Int])[1])"
      cellAccessibilityString = "\((numbers as! [Int])[0])" + opAccessibilityString + "\((numbers as! [Int])[1])"
    case "ruler":
      if (operation as! String) == "COMPARE-BIG" || (operation as! String) == "COMPARE-MIDDLE" || (operation as! String) == "COMPARE-SMALL" {
        cell!.textLabel!.text = "\((numbers as! [Int])[0]), \((numbers as! [Int])[1]), \((numbers as! [Int])[2]) (\(op))"
      } else {
        cell!.textLabel!.text = "\(operation as! String) (\((numbers as! [Int])[0]))"
      }
      cellAccessibilityString = cell!.textLabel!.text!
    case "algebra":
      var formattedString = ""
      if (numbers as! [String])[0] != "" {
        formattedString += (numbers as! [String])[0]
      }
      if (numbers as! [String])[0] != "" && (numbers as! [String])[1] != "" && !(numbers as! [String])[1].hasPrefix("-") {
        formattedString += "+"
      }
      formattedString += (numbers as! [String])[1] + " = " + (numbers as! [String])[2]
      if (numbers as! [String])[2] != "" && (numbers as! [String])[3] != "" && !(numbers as! [String])[3].hasPrefix("-") {
        formattedString += "+"
      }
      formattedString += (numbers as! [String])[3] + " (\(op))"
      cell!.textLabel!.text = formattedString

      if (numbers as! [String])[0] != "" {
        if !(numbers as! [String])[0].hasPrefix("-") {
          cellAccessibilityString = (numbers as! [String])[0]
        } else {
          cellAccessibilityString = "負" + (numbers as! [String])[0].substringFromIndex(advance((numbers as! [String])[0].startIndex, 1))
        }
        if (numbers as! [String])[1] != "" {
          if !(numbers as! [String])[1].hasPrefix("-") {
            cellAccessibilityString = cellAccessibilityString + "加" + (numbers as! [String])[1] + "等如"
          } else {
            cellAccessibilityString = cellAccessibilityString + "減" + (numbers as! [String])[1].substringFromIndex(advance((numbers as! [String])[1].startIndex, 1)) + "等如"
          }
        } else {
          cellAccessibilityString += "等如"
        }
      } else {
        if !(numbers as! [String])[1].hasPrefix("-") {
          cellAccessibilityString = (numbers as! [String])[1] + "等如"
        } else {
          cellAccessibilityString = "負" + (numbers as! [String])[1].substringFromIndex(advance((numbers as! [String])[1].startIndex, 1)) + "等如"
        }
      }
      
      if (numbers as! [String])[2] != "" {
        if !(numbers as! [String])[2].hasPrefix("-") {
          cellAccessibilityString = cellAccessibilityString + (numbers as! [String])[2]
        } else {
          cellAccessibilityString = cellAccessibilityString + "負" + (numbers as! [String])[2].substringFromIndex(advance((numbers as! [String])[2].startIndex, 1))
        }
        if (numbers as! [String])[3] != "" {
          if !(numbers as! [String])[3].hasPrefix("-") {
            cellAccessibilityString = cellAccessibilityString + "加" + (numbers as! [String])[3]
          } else {
            cellAccessibilityString = cellAccessibilityString + "減" + (numbers as! [String])[3].substringFromIndex(advance((numbers as! [String])[3].startIndex, 1))
          }
        }
      } else {
        if !(numbers as! [String])[3].hasPrefix("-") {
          cellAccessibilityString = cellAccessibilityString + (numbers as! [String])[3]
        } else {
          cellAccessibilityString = cellAccessibilityString + "負" + (numbers as! [String])[3].substringFromIndex(advance((numbers as! [String])[3].startIndex, 1))
        }
      }
      AppUtil.log(cellAccessibilityString)
    default:
      break
    }
    
    cell!.accessibilityLabel = "第" + String(row+1) + "條問題" + cellAccessibilityString
    if (selected as! Bool) {
      cell?.accessoryView = UIImageView(image: UIImage(named: "checkmark"))
      cell!.accessibilityLabel = cell!.accessibilityLabel + "已選"
    } else {
      cell?.accessoryView = nil
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    let row = indexPath.row
    var customQuestion = questionsBank[row] as! Dictionary<String, AnyObject>
    var operation: AnyObject = customQuestion["Operation"]!
    var selected: AnyObject = customQuestion["Selected"]!
    var numbers: AnyObject = customQuestion["Numbers"]!
    var cell = tableView.cellForRowAtIndexPath(indexPath)
    
    if (selected as! Bool) {
      customQuestion["Selected"] = false
      cell?.accessoryView = nil
    } else {
      customQuestion["Selected"] = true
      cell?.accessoryView = UIImageView(image: UIImage(named: "checkmark"))
    }
    
    questionsBank[row] = customQuestion
    saveQuestions()
    
//    tableView.reloadData()  // no need to reload, if reload, will lost current position
  }

  func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      // Update the questions bank
      [questionsBank .removeObjectAtIndex(indexPath.row)]
      saveQuestions()
      
      questionsTable.reloadData()
    }
  }
  
  // MARK: - Gestures
  
  override func accessibilityPerformEscape() -> Bool {
    backBtnClicked(0)
    
    return true
  }
}
