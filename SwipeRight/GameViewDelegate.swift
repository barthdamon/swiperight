//
//  GameViewDelegate.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/11/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

protocol GameViewDelegate {
  func setStreakLabels(callback: (Bool) ->())
  func beginGame()
  func scoreChange(correct: Bool)
  func startGameplay()
  func resetGameState()
  func setStartTime()
  func resetGameUI()
  func configureStartOptions()
  func resetClientOperations(currentOperations: Array<Operation>?)
  func addTime(seconds: Int)
  func gameOver(finished: Bool)
  func setRound(number: Int)
  func getWidth() -> CGFloat
  func toggleHelperMode(on: Bool)
  func setHelperPoints(points: Int, callback: (Bool) -> ())
  func togglePaused(paused: Bool)
  func deactivateHelperPointButton(remove: Bool, deactivate: Bool)
  func setGameViewController(controller: GameViewController)
  
  
  //MARK: Tutorial
  func setBlinkingTimerOn(on: Bool)
  func setBlinkingOperationsOn(on: Bool)
  func setBlinkingHelperPointsOn(on: Bool, withStreaks: Bool, hideStreaks: Bool)
  func setTutorialLabelText(text: String?)
  func hideBonusButtonView()
}