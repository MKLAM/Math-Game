//
//  HelpViewController.swift
//  Math Game
//
//  Created by Richard on 2/7/15.
//  Copyright (c) 2015 OEM. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

  @IBOutlet weak var helpTextView: UITextView!
  
  @IBOutlet weak var sample1Btn: UIButton!
  @IBOutlet weak var sample2Btn: UIButton!
  @IBOutlet weak var sample3Btn: UIButton!
  @IBOutlet weak var sample4Btn: UIButton!
  
  var gameType = ""
  var html = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()

    sample1Btn.hidden = true
    sample2Btn.hidden = true
    sample3Btn.hidden = true
    sample4Btn.hidden = true
    
    switch gameType {
      case "fraction":
        html = "<p style=\"font-size:32px\"><b>分數運算</b></p><ol style=\"font-size:28px\"><li>點選分數的分子或分母<li>輸入數值，並約簡成為最簡分數<li>完成後按確定<li>到下一題</ol>"
        html = html + "<br><br><br><p style=\"font-size:32px\"><b>Voice-Over系統:</b></p><ol style=\"font-size:28px\"><li>進入遊戲後，移標顯示在問題<li>單指左或右移動到分子或分母的文字欄位，然後點兩下確定編輯<li>左或右移動揀選數值，點兩下確定及輸入數值<li>輸入完成後，揀選刪除、確定或取消<li>把答案約簡<li>完成後按確定<li>到下一題</ol>"
      
        sample1Btn.hidden = false
        sample1Btn.setTitle("加數例題", forState: UIControlState.Normal)
        sample2Btn.hidden = false
        sample2Btn.setTitle("減數例題", forState: UIControlState.Normal)
        sample3Btn.hidden = false
        sample3Btn.setTitle("乘數例題", forState: UIControlState.Normal)
        sample4Btn.hidden = false
        sample4Btn.setTitle("除數例題", forState: UIControlState.Normal)
      case "longCalc":
        html = "<p style=\"font-size:32px\"><b>直式</b></p><ol style=\"font-size:28px\"><li>點選文字欄位<li>輸入加、減、乘或除直式的和、差、餘數、商<li>完成後按確定<li>到下一題</ol>"
        html = html + "<br><br><br><p style=\"font-size:32px\"><b>Voice-Over系統:</b></p><ol style=\"font-size:28px\"><li>進入遊戲後，移標顯示在”問題”<li>單指左或右移動到適當的文字欄位，然後點兩下確定編輯<li>左或右移動揀選數值，點兩下確定輸入數值<li>輸入完成後揀選刪除、確定或取消<li>計算出正確的答案<li>到下一題</ol>"

        sample1Btn.hidden = false
        sample1Btn.setTitle("加數例題", forState: UIControlState.Normal)
        sample2Btn.hidden = false
        sample2Btn.setTitle("減數例題", forState: UIControlState.Normal)
        sample3Btn.hidden = false
        sample3Btn.setTitle("乘數例題", forState: UIControlState.Normal)
        sample4Btn.hidden = false
        sample4Btn.setTitle("除數例題", forState: UIControlState.Normal)
      case "ruler":
        html = "<p style=\"font-size:32px\"><b>數尺</b></p><ol style=\"font-size:28px\">計算題目<li>按上一頁或下一頁，在負50和正50之間移動數尺<li>點選正確的答案<li>到下一題</ol>"
        html = html + "<br><br><br><p style=\"font-size:32px\"><b>Voice-Over系統:</b></p><ol style=\"font-size:28px\"><li>進入遊戲後，移標顯示在”問題”<li>三指左或右移動到適當數值的範圍<li>單指左或右移動到適當的數值，然後點兩下確定<li>到下一題</ol>"
      case "algebra":
        html = "<p style=\"font-size:32px\"><b>方程式</b></p><ol style=\"font-size:28px\"><li>計算題目<li>運用天秤法，在方程的左邊和右邊輸入對稱的運算數值<li>單指左或右移動到”完成”，並運算成最簡方程式<li>到下一題</ol>"
        html = html + "<br><br><br><p style=\"font-size:32px\"><b>Voice-Over系統:</b></p><ol style=\"font-size:28px\"><li>進入遊戲後，移標顯示在”問題”<li>單指左或右移動到適當的文字欄位，然後點兩下確定編輯。包括左方的第一輸入、數符和第二輸入 及 右方的第一輸入、數符和第二輸入。<li>單指左或右移動到”完成”，並運算成最簡方程式<li>到下一題"
      default:
        html = ""
    }
    
    var attrStr = NSMutableAttributedString(
      data: html.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
      options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
      documentAttributes: nil,
      error: nil)
    helpTextView.attributedText = attrStr
}
  
  // MARK: - Main
  
  func initGameType(type: String) {
    gameType = type
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let segueID:String = segue.identifier!
    
    if (segueID == "showTutorial1") || (segueID == "showTutorial2") || (segueID == "showTutorial3") || (segueID == "showTutorial4") {
      switch gameType {
        case "fraction", "longCalc":
          let vc = segue.destinationViewController as! TutorialViewController
          switch (sender as! UIButton).tag {
          case 41:
            vc.initTutorialType(gameType + "Add")
          case 42:
            vc.initTutorialType(gameType + "Subtract")
          case 43:
            vc.initTutorialType(gameType + "Multiply")
          case 44:
            vc.initTutorialType(gameType + "Divide")
          default:
            break
          }
        default:
          break
      }
    }
  }
  
  @IBAction func backBtnClicked(sender: UIButton) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
