//
//  TutorialViewController.swift
//  Math Game
//
//  Created by Richard on 14/3/15.
//  Copyright (c) 2015 OEM. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

  var tutorialType = ""
  
  @IBOutlet weak var fractionAddTutorialView: UIView!
  @IBOutlet weak var fractionSubtractTutorialView: UIView!
  @IBOutlet weak var fractionMultiplyTutorialView: UIView!
  @IBOutlet weak var fractionDivideTutorialView: UIView!
  @IBOutlet weak var longCalcAddTutorialView: CustomUIView!
  @IBOutlet weak var longCalcSubtractTutorialView: CustomUIView!
  @IBOutlet weak var longCalcMultiplyTutorialView: CustomUIView!
  @IBOutlet weak var longCalcDivideTutorialView: CustomUIView!
  
  @IBOutlet weak var A0: UILabel!
  @IBOutlet weak var A1: UILabel!
  @IBOutlet weak var A2: UIImageView!
  @IBOutlet weak var A3: UILabel!
  @IBOutlet weak var A4: UIImageView!
  @IBOutlet weak var A5: UILabel!
  @IBOutlet weak var A6: UIImageView!
  @IBOutlet weak var A7: UILabel!
  @IBOutlet weak var A8: UIImageView!
  @IBOutlet weak var A9: UILabel!
  @IBOutlet weak var A10: UIImageView!
  @IBOutlet weak var A11: UILabel!
  @IBOutlet weak var A12: UIImageView!
  @IBOutlet weak var A13: UILabel!
  @IBOutlet weak var A14: UIImageView!
  @IBOutlet weak var A15: UILabel!
  @IBOutlet weak var A16: UIImageView!
  @IBOutlet weak var A17: UILabel!
  @IBOutlet weak var A18: UIImageView!
  @IBOutlet weak var A19: UILabel!
  @IBOutlet weak var A20: UIImageView!
  @IBOutlet weak var A21: UILabel!
  @IBOutlet weak var A22: UIImageView!
  @IBOutlet weak var A23: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fractionAddTutorialView.hidden = true
    fractionSubtractTutorialView.hidden = true
    fractionMultiplyTutorialView.hidden = true
    fractionDivideTutorialView.hidden = true
    longCalcAddTutorialView.hidden = true
    longCalcSubtractTutorialView.hidden = true
    longCalcMultiplyTutorialView.hidden = true
    longCalcDivideTutorialView.hidden = true

    switch tutorialType {
      case "fractionAdd":
        fractionAddTutorialView.hidden = false
        fractionAddTutorialView.accessibilityElements = [A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23]
        A0.accessibilityLabel = "8份6加4份3,分母不相同。先通分母，利用列舉法找出分母公倍數8，進行擴分使分母都是8的分數，8份6分母是8，不用擴分，4份3分母乘以2變成8, 分子也要乘以2，4份3就變成8份6。這題異分母加法就變成8份6加8份6同分母加法，分母係8，分子係6加6，成為8份12，最後約簡，得出答案2份3。"
        A1.accessibilityLabel = "第一步第一份數份子6"
        A2.accessibilityLabel = "份線"
        A3.accessibilityLabel = "第一步第一份數份母8"
        A4.accessibilityLabel = "加"
        A5.accessibilityLabel = "第一步第二份數份子3"
        A6.accessibilityLabel = "份線"
        A7.accessibilityLabel = "第一步第二份數份母4"
        A8.accessibilityLabel = "等如"
        A9.accessibilityLabel = "第二步第一份數份子6"
        A10.accessibilityLabel = "份線"
        A11.accessibilityLabel = "第二步第一份數份母8"
        A12.accessibilityLabel = "加"
        A13.accessibilityLabel = "第二步第二份數份子6"
        A14.accessibilityLabel = "份線"
        A15.accessibilityLabel = "第二步第二份數份母8"
        A16.accessibilityLabel = "等如"
        A17.accessibilityLabel = "第三步份數份子12"
        A18.accessibilityLabel = "份線"
        A19.accessibilityLabel = "第三步份數份母8"
        A20.accessibilityLabel = "等如"
        A21.accessibilityLabel = "第四步份數份子3"
        A22.accessibilityLabel = "份線"
        A23.accessibilityLabel = "第四步份數份母2"
      case "fractionSubtract":
        fractionSubtractTutorialView.hidden = false
        fractionSubtractTutorialView.accessibilityElements = [A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23]
        A0.accessibilityLabel = "8份6減4份1,分母不相同。先通分母，利用列舉法找出分母公倍數8，進行擴分使分母都是8的分數，8份6分母是8，不用擴分，4份1分母乘以2變成8, 分子也要乘以2，4份1就變成8份2。這題異分母加法就變成8份6減8份2同分母加法，分母係8，分子係6減2，成為8份4，最後約簡，得出答案2份1。"
        A1.accessibilityLabel = "第一步第一份數份子6"
        A2.accessibilityLabel = "份線"
        A3.accessibilityLabel = "第一步第一份數份母8"
        A4.accessibilityLabel = "減"
        A5.accessibilityLabel = "第一步第二份數份子1"
        A6.accessibilityLabel = "份線"
        A7.accessibilityLabel = "第一步第二份數份母4"
        A8.accessibilityLabel = "等如"
        A9.accessibilityLabel = "第二步第一份數份子6"
        A10.accessibilityLabel = "份線"
        A11.accessibilityLabel = "第二步第一份數份母8"
        A12.accessibilityLabel = "減"
        A13.accessibilityLabel = "第二步第二份數份子2"
        A14.accessibilityLabel = "份線"
        A15.accessibilityLabel = "第二步第二份數份母8"
        A16.accessibilityLabel = "等如"
        A17.accessibilityLabel = "第三步份數份子4"
        A18.accessibilityLabel = "份線"
        A19.accessibilityLabel = "第三步份數份母8"
        A20.accessibilityLabel = "等如"
        A21.accessibilityLabel = "第四步份數份子1"
        A22.accessibilityLabel = "份線"
        A23.accessibilityLabel = "第四步份數份母2"
      case "fractionMultiply":
        fractionMultiplyTutorialView.hidden = false
        fractionMultiplyTutorialView.accessibilityElements = [A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23]
        A0.accessibilityLabel = "5份3乘9份1, 如可以約簡就先約簡，第一分子3和第二分母9互相約簡，就等如5份1乘3份1，先處理分子部份，1乘1等於1，然後處理分母部份5乘3等於15, 答案就是15份1, 如可以約簡, 就必需約簡。"
        A1.accessibilityLabel = "第一步第一份數份子3"
        A2.accessibilityLabel = "份線"
        A3.accessibilityLabel = "第一步第一份數份母5"
        A4.accessibilityLabel = "乘"
        A5.accessibilityLabel = "第一步第二份數份子1"
        A6.accessibilityLabel = "份線"
        A7.accessibilityLabel = "第一步第二份數份母9"
        A8.accessibilityLabel = "等如"
        A9.accessibilityLabel = "第二步第一份數份子1"
        A10.accessibilityLabel = "份線"
        A11.accessibilityLabel = "第二步第一份數份母5"
        A12.accessibilityLabel = "乘"
        A13.accessibilityLabel = "第二步第二份數份子1"
        A14.accessibilityLabel = "份線"
        A15.accessibilityLabel = "第二步第二份數份母3"
        A16.accessibilityLabel = "等如"
        A17.accessibilityLabel = "第三步份數份子1"
        A18.accessibilityLabel = "份線"
        A19.accessibilityLabel = "第三步份數份母15"
      case "fractionDivide":
        fractionDivideTutorialView.hidden = false
        fractionDivideTutorialView.accessibilityElements = [A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19]
        A0.accessibilityLabel = "3份2除3份4，移除作乘，分子分母痲倒，意思把除號移去變成乘號，而且把第二分數的分子分母對調，變成3份2乘4份3，約簡之後答案便是2份1。"
        A1.accessibilityLabel = "第一步第一份數份子2"
        A2.accessibilityLabel = "份線"
        A3.accessibilityLabel = "第一步第一份數份母3"
        A4.accessibilityLabel = "除"
        A5.accessibilityLabel = "第一步第二份數份子4"
        A6.accessibilityLabel = "份線"
        A7.accessibilityLabel = "第一步第二份數份母3"
        A8.accessibilityLabel = "等如"
        A9.accessibilityLabel = "第二步第一份數份子2"
        A10.accessibilityLabel = "份線"
        A11.accessibilityLabel = "第二步第一份數份母3"
        A12.accessibilityLabel = "乘"
        A13.accessibilityLabel = "第二步第二份數份子3"
        A14.accessibilityLabel = "份線"
        A15.accessibilityLabel = "第二步第二份數份母4"
        A16.accessibilityLabel = "等如"
        A17.accessibilityLabel = "第三步份數份子1"
        A18.accessibilityLabel = "份線"
        A19.accessibilityLabel = "第三步份數份母2"
      case "longCalcAdd":
        longCalcAddTutorialView.hidden = false
      case "longCalcSubtract":
        longCalcSubtractTutorialView.hidden = false
      case "longCalcMultiply":
        longCalcMultiplyTutorialView.hidden = false
      case "longCalcDivide":
        longCalcDivideTutorialView.hidden = false
      case "ruler":
break
    case "algebra":
break
    default:
        break
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func backBtnClicked(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func initTutorialType(type: String) {
    tutorialType = type
  }

}
