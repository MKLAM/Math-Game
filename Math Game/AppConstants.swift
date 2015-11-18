//
//  Constants.swift
//  Math Game
//
//  Created by Richard on 10/10/14.
//  Copyright (c) 2014 OEM. All rights reserved.
//
import UIKit
import Foundation

// Voice prompts
struct Voices {
  static let fieldIsFull = "填滿了"
  static let answerCorrect = "答對了"
  static let answerIncorrect = "吾啱播"
  static let keyboardIsShown = ""
  static let keyboardIsHidden = ""
  static let gotoNextStep = "下一步"
  static let goHomePage = "返回主頁"
}

struct QuestionCount {
  static var fraction = 0
  static var longCalc = 0
  static var ruler = 0
  static var algebra = 0
}

class LongCalcParam {
  let addEasyLimit: UInt32 = 99
  let addDifficultLimit: UInt32 = 999
  let subtractEasyLimit: UInt32 = 99
  let subtractDifficultLimit: UInt32 = 999
  
  let multiplyOp1Easy: UInt32 = 19
  let multiplyOp2Easy: UInt32 = 9
  let multiplyOp1Difficult: UInt32 = 999
  let multiplyOp2Difficult: UInt32 = 99

  let divideOp1Easy: UInt32 = 9
  let divideOp2Easy: UInt32 = 99
  let divideOp1Difficult: UInt32 = 99
  let divideOp2Difficult: UInt32 = 999
}

class FractionParam {
  let easyLimit: UInt32 = 9
  let difficultLimit: UInt32 = 50
}

class AlgebraParam {
  let xCoeff: UInt32 = 20
  let xAnswerEasy: UInt32 = 9
  let xAnswerDifficult: UInt32 = 20
  let numCoeff: UInt32 = 20
}

class RulerParam {
  let numMax: UInt32 = 20
}

