//
//  ViewController.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/9/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

typealias Coordinates = (x: CGFloat, y: CGFloat)
typealias GridCoordinates = (x: Int, y: Int)
typealias NumberCombination = (x: Int, b: Int, y: Int, operation: Operation)

enum Operation {
  case Divide
  case Subtract
  case Add
  case Multiply
}

class ViewController: UIViewController {

  @IBOutlet weak var topScoreLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  
  var gameView: UIView?
  var tileViews: Array<UIView> = []
  //NOTE: ALL TILES START AT 0 INSTEAD OF ONE DONT GET CONFUSED
  var tileCoordinates: Array<GridCoordinates> = [(x:0, y:0), (x:1, y:0), (x:2, y:0), (x:0, y:1), (x:1, y:1), (x:2, y:1), (x:0, y:2), (x:1, y:2), (x:2, y:2)]
  let operations: Array<Operation> = [.Add, .Divide, .Subtract, .Multiply]
  let gridDirections: Array<GridDirection> = [.Diagonal, .Horizontal, .Vertical]
  
  var numberGrid: Array<Int>?
  var nextNumberGrid: Array<Int>?
  
  var startLoc: CGPoint?
  var endLoc: CGPoint?
  var middleLocs: Array<CGPoint> = []
  var viewWidth: CGFloat = 0
  var gameViewWidth: CGFloat = 0
  var tileWidth: CGFloat = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewWidth = self.view.frame.width
    configureGameView()
  }
  
  
  //MARK: TILE FUNCTIONALITY
  func configureGameView() {
    let offset = (viewWidth - (viewWidth / 1.25)) / 2
    gameView = UIView(frame: CGRectMake(offset, 210, viewWidth / 1.25, viewWidth / 1.25))
    gameViewWidth = gameView!.frame.width
    tileWidth = gameViewWidth / 3
    gameView?.backgroundColor = UIColor.darkGrayColor()
    self.view.addSubview(gameView!)
    addGestureRecognizers(gameView!)
    configureGameViewComponents(gameView!)
  }
  
  func addGestureRecognizers(gameView: UIView) {
    let swipeRecognizer = UIPanGestureRecognizer(target: self, action: "gameViewSwiped:")
    swipeRecognizer.minimumNumberOfTouches = 1
    gameView.addGestureRecognizer(swipeRecognizer)
  }
  
  func configureGameViewComponents(gameView: UIView) {
    var coords = Coordinates(x: 0, y: 0)
    
    func adjustCoords(i: Int) {
      coords.x = coords.x + tileWidth
      if i == 2 || i == 5  {
        coords.x = 0
        coords.y = coords.y + tileWidth
      }
    }
    
    for var i = 0; i < 9; i++ {
      let tileView = UIView(frame: CGRectMake(coords.x, coords.y, tileWidth, tileWidth))
      tileView.backgroundColor = UIColor.cyanColor()
      let numberLabel = UILabel(frame: CGRectMake(tileWidth / 2.1, tileWidth / 5.2, tileWidth / 2, tileWidth / 2))
      numberLabel.text = "2"
      tileView.addSubview(numberLabel)
      tileViews.append(tileView)
      adjustCoords(i)
      gameView.addSubview(tileView)
    }
  }
  
  func resolveUserInteraction() {
    if let startLoc = startLoc, endLoc = endLoc {
      var startTile: UIView?
      var endTile: UIView?
      var midTile: UIView?
      //Int floors the cgfloat
      let start = (x: Int(startLoc.x / tileWidth), y: Int(startLoc.y / tileWidth))
      print("START: \(start.x), \(start.y)")
      let end = (x: Int(endLoc.x / tileWidth), y: Int(endLoc.y / tileWidth))
      print("END: \(end.x), \(end.y)")
      let mid = (x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
      print("MIDDLE: \(mid.x), \(mid.y)")
      
      for var i = 0; i < tileCoordinates.count; i++ {
        let loc = tileCoordinates[i]
        if loc.x == start.x && loc.y == start.y {
          startTile = tileViews[i]
          print("START TILE FOUND: \(i)")
        }
        if loc.x == end.x && loc.y == end.y {
          endTile = tileViews[i]
          print("END TILE FOUND: \(i)")
        }
        if loc.x == mid.x && loc.y == mid.y {
          midTile = tileViews[i]
          print("MID TILE FOUND: \(i)")
        }
      }
      
      if let startTile = startTile, midTile = midTile, endTile = endTile {
        tileRespond(startTile, middleTile: midTile, endTile: endTile)
        self.startLoc = nil
        self.endLoc = nil
      }
    }
  }
  
  func tileRespond(startTile: UIView, middleTile: UIView, endTile: UIView) {
    print("TILE RESPOND TIME")
    startTile.backgroundColor = UIColor.redColor()
    endTile.backgroundColor = UIColor.redColor()
    middleTile.backgroundColor = UIColor.redColor()
    
    resetTiles()
  }
  
  func resetTiles() {
    tileViews.forEach { (tile) -> () in
      UIView.animateWithDuration(1, animations: { () -> Void in
        tile.backgroundColor = UIColor.cyanColor()
        }, completion: { (complete) -> Void in
          //RESET TILES HERE WITH NEW NUMBERS
      })
    }
  }
  
  func gameViewSwiped(sender: UIGestureRecognizer) {
    let loc = sender.locationInView(gameView)
    if sender.state == .Began {
      startLoc = loc
      print("Gesture Began: \(loc)")
      resolveUserInteraction()
    }
    if sender.state == .Ended {
      endLoc = loc
      print("Gesture Ended \(loc)")
      resolveUserInteraction()
    }
  }
  
  
  
  
  
  
  //MARK: Number Functionality

  func generateNumberGrid() {
    let solution = generateWinningSolution()
    if let solution = solution {
      populateRestOfGrid(solution)
    }
  }
  
  func generateWinningSolution() -> NumberCombination? {
    //    let randomOperationIndex = randoNumber(minX: 0, maxX: 3)
    //    let currentOperation = operations[randomOperationIndex]
    let currentOperation = Operation.Add
    
    var winningCombo: NumberCombination
    let randomSolution = randoNumber(minX:0, maxX:UInt32(100))
    
    switch currentOperation {
    case .Add:
      let firstNumber = randoNumber(minX: 0, maxX: UInt32(randomSolution))
      let secondNumber = randomSolution - firstNumber
      winningCombo = (x: firstNumber, b: secondNumber, y: randomSolution, operation: currentOperation)
      return winningCombo
    case .Divide:
      break
    case .Multiply:
      break
    case .Subtract:
      break
    }
  }
  
  
  //randomization:
  // [(x:0, y:0), (x:1, y:0), (x:2, y:0), (x:0, y:1), (x:1, y:1), (x:2, y:1), (x:0, y:2), (x:1, y:2), (x:2, y:2)]
  //X combos: all the same, one of each, or all different
  //Y combos based on X combos: all same: all different, all different: allsame, one of each: one of each
  
  enum GridDirection {
    case Horizontal
    //all same vs all different
    case Vertical
    case Diagonal
    //one of each
  }
  
  func populateRestOfGrid(solution: NumberCombination) {
    //should only need three numberCombinations in this array
    var numbers : Array<NumberCombination> = [solution]
    let thisOperation = solution.operation
    
    let randomGridPositionIndex = randoNumber(minX: 0, maxX: UInt32(8))
    let randomDirectionIndex = randoNumber(minX: 0, maxX: 2)
    
    let solutionDirection = gridDirections[randomDirectionIndex]
    let solutionPosition = tileCoordinates[randomGridPositionIndex]
    
    //how the fuck do you translate a random direction with the array of grid numbers though
    
    //basically need to layout a fake grid and do all the math on it until the numbers all work
    let gridLayout = [0,0,0,0,0,0,0,0,0]
    
    switch thisOperation {
    case .Add:
      
      break
    case .Subtract:
      break
    case .Divide:
      break
    case .Multiply:
      break
    }
  }
  
  //Random number generator
  func randoNumber(minX minX:UInt32, maxX:UInt32) -> Int {
    let result = (arc4random() % (maxX - minX + 1)) + minX
    return Int(result)
  }

}

