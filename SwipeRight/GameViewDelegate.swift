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
  func setStreakLabel()
  func beginGame()
  func scoreChange(correct: Bool)
  func startGameplay()
  func resetGameState()
  func setStartTime()
  func configureStartOptions()
  func toggleClientView()
  func resetClientOperations(currentOperations: Array<Operation>?)
  func addTime(seconds: Int)
  func gameOver(finished: Bool)
  func setRound(number: Int)
  func getWidth() -> CGFloat
  func toggleHelperMode(on: Bool)
  func setHelperPoints(points: Int)
  func togglePaused(paused: Bool)
  func deactivateHelperPointButton(remove: Bool, deactivate: Bool)
  func setGameViewController(controller: GameViewController)
}