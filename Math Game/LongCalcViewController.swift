//
//  LongCalcViewController.swift
//  Math Game
//
//  Created by Richard on 18/9/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//

import UIKit

class LongCalcViewController: UIViewController {
  
  @IBOutlet var containerView: UIView!
  @IBOutlet weak var backBtn: UIButton!
  @IBOutlet weak var nextQuestionBtn: UIButton!
  @IBOutlet weak var redoBtn: UIButton!
  
  @IBOutlet weak var gridView: UIView!
  @IBOutlet weak var gridImage: UIImageView!
  
  let addSubtractViewController = AddSubtractViewController(nibName: "AddSubtractViewController", bundle: nil)
  let multiplyViewController = MultiplyViewController(nibName: "MultiplyViewController", bundle: nil)
  let divideViewController = DivideViewController(nibName: "DivideViewController", bundle: nil)
  
  var currOp = OpType.Multiply
  var currViewController = UIViewController()

  var difficultyLevel = DifficultyLevel.Easy
  
  var questionsBank = []
  
  var doAdd = true
  var doSubtract = true
  var doMultiply = true
  var doDivide = true

  // MARK: - View
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Read in the question bank
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
    let documentsDirectory = paths.objectAtIndex(0) as! NSString
    let filePath = documentsDirectory.stringByAppendingPathComponent("LongCalcQuestions.plist")
    
    questionsBank = NSArray(contentsOfFile: filePath)!
    AppUtil.log("There are \(questionsBank.count) questions for long calculation")
    
    // See what operations are allowed
    let userDefaults = NSUserDefaults()
    doAdd = userDefaults.objectForKey("longCalcAdd") as! Bool
    doSubtract = userDefaults.objectForKey("longCalcSubtract") as! Bool
    doMultiply = userDefaults.objectForKey("longCalcMultiply") as! Bool
    doDivide = userDefaults.objectForKey("longCalcDivide") as! Bool
    
    // In case no operation is allowed, then do Addition
    if !doAdd && !doSubtract && !doMultiply && !doDivide {
      doAdd = true
    }
    
    nextQuestionBtnClicked(0)
    
    // Enable/Disable the bottom buttons when the user is editing the field
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "disableFieldsWhenBeginEditing", name: "beginEditing", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableFieldsWhenEndEditing", name: "endEditing", object: nil)
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
    var op1 = 0
    var op2 = 0
    
    if difficultyLevel == DifficultyLevel.Easy || difficultyLevel == DifficultyLevel.Difficult {
      var num: UInt32 = 0
      do {   // keep on looking for an operation that is allowed
        num = arc4random_uniform(4)  // 0..3 for +-*/
      } while !(num == 0 && doAdd) && !(num == 1 && doSubtract) && !(num == 2 && doMultiply) && !(num == 3 && doDivide)
      
      switch num {
      case 0:
        currOp = .Add
      case 1:
        currOp = .Subtract
      case 2:
        currOp = .Multiply
      case 3:
        currOp = .Divide
      default:
        break
      }
    } else {   // custom questions
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
        currOp = .Add
      case "SUBTRACT":
        currOp = .Subtract
      case "MULTIPLY":
        currOp = .Multiply
      case "DIVIDE":
        currOp = .Divide
      default:
        println("Should not happen")
      }

      op1 = (numbers as! [Int])[0]
      op2 = (numbers as! [Int])[1]
    }
    
    loadViewController(currOp)
    
    switch currOp {
    case .Add:
      addSubtractViewController.genNewQuestion(OpType.Add, level:difficultyLevel, customOperand1:op1, customOperand2:op2)
    case .Subtract:
      addSubtractViewController.genNewQuestion(OpType.Subtract, level:difficultyLevel, customOperand1:op1, customOperand2:op2)
    case .Multiply:
      multiplyViewController.genNewQuestion(difficultyLevel, customOperand1:op1, customOperand2:op2)
    case .Divide:
      divideViewController.genNewQuestion(difficultyLevel, customOperand1:op1, customOperand2:op2)
    }
  }
  
  @IBAction func redoBtnClicked(sender: AnyObject) {
    switch currOp {
    case .Add:
      addSubtractViewController.redoBtnClicked()
    case .Subtract:
      addSubtractViewController.redoBtnClicked()
    case .Multiply:
      multiplyViewController.redoBtnClicked()
    case .Divide:
      divideViewController.redoBtnClicked()
    }
  }
  
  // MARK: - Main
  
  func loadViewController(op: OpType) {
    // First get rid of any existing child controller
    if childViewControllers.count > 0 {
      let oldViewController = childViewControllers[0] as! UIViewController
      oldViewController.willMoveToParentViewController(nil)
      oldViewController.removeFromParentViewController()
      oldViewController.view.removeFromSuperview()
    }
    
    switch op {
    case .Add:
      currViewController = addSubtractViewController
    case .Subtract:
      currViewController = addSubtractViewController
    case .Multiply:
      currViewController = multiplyViewController
    case .Divide:
      currViewController = divideViewController
    }

    addChildViewController(currViewController)
    var destView = currViewController.view
    destView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    destView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height)
    containerView.addSubview(destView)
    currViewController.didMoveToParentViewController(self)
  }

  func setDifficultyLevel(level: DifficultyLevel) {
    difficultyLevel = level
  }
  
  func disableFieldsWhenBeginEditing() {
    // Hiding the fields is good enough to avoid VO
    backBtn.hidden = true
    nextQuestionBtn.hidden = true
    redoBtn.hidden = true
  }
  
  func enableFieldsWhenEndEditing() {
    backBtn.hidden = false
    nextQuestionBtn.hidden = false
    redoBtn.hidden = false
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nextQuestionBtn)
  }
  
  // MARK: - Gestures
  
  override func accessibilityPerformEscape() -> Bool {
    backBtnClicked(0)
    
    return true
  }
}
