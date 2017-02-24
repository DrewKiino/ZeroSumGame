//
//  ViewController.swift
//  ZeroSumGame
//
//  Created by Andrew Aquino on 2/22/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import UIKit
import ScrollableGraphView
import Neon

let screen = UIScreen.main.bounds

class ViewController: UIViewController {

  var chosenPlayer: String!
  var winningPlayer: String!
  var opposingPlayer: String!
  var losingPlayer: String!
  var currentTurn = 0

  var globalSum: Double = 1.0

  var players: [String: Double] = [
    "Matt": 1.0,
    "Harry": 1.0,
    "James": 1.0,
    "Eldron": 1.0
//    "Kenny": 1.0,
//    "Jose": 1.0,
//    "Veronica": 1.0,
//    "Mandy": 1.0,
//    "Ike": 1.0,
//    "joseph": 1.0
  ]
  var score: [String: Double] = [:]
  
  var labels = [UILabel]()
  var titleLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    setupUI()
    startGame(speed: 0.001)
    
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] timer in
      self?.animate()
    }
  }
  
  func setupUI() {
    
    titleLabel.text = "Zero Sum Game"
    titleLabel.textAlignment = .center
    view.addSubview(titleLabel)
    
    labels = players.map { player, talent -> UILabel in
      let label = UILabel()
      label.text = player
      label.backgroundColor  = .randomColor()
      label.textAlignment = .center
      label.layer.borderColor = UIColor.black.cgColor
      label.layer.borderWidth = 1.0
      label.numberOfLines = 0
      return label
    }
    labels.forEach { [weak self] label in
      self?.view.addSubview(label)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    titleLabel.anchorToEdge(.top, padding: 100, width: screen.width, height: 48)
  }
  
  func animate() {
    
    let labelCount = labels.count
    let divisor = (screen.width - 16) / CGFloat(labelCount)
    var originX: CGFloat = 8
    let players = Array(self.players)
    
    labels.enumerated().forEach { [weak self] index, label in
      if let scores = self?.score {
        let score = CGFloat(Array(scores)[index].value)
        let playerName = players[index]
        label.text = "\(playerName.key)\n\(Double(score).roundTo(places: 2))"
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { [weak label] in
          label?.frame = CGRect(x: originX, y: screen.height / 2, width: divisor - 8, height: -score)
          originX += divisor
        }, completion: nil)
      }
    }
//    print(getWinningPlayer())
//    print(getLosingPlayer())
    print(globalSum)
  }
  
  func roll() {
//    chosenPlayer = getRandomConditionThenPlayer()
    //    chosenPlayer = getLastPlayer()
//        chosenPlayer = getNextPlayer()
//    chosenPlayer = getWinningPlayer()
    chosenPlayer = getRandomPlayer()
//    chosenPlayer = getRandomPlayerExclusive(player: chosenPlayer)
//    chosenPlayer = getWinningPlayer()
//    chosenPlayer = getLosingPlayer()
//    print(chosenPlayer)
    var playerRoll = Double.random().roundTo(places: 2)
    if let roll = players[chosenPlayer], roll > 1.0 { playerRoll *= roll }
    
    //  let randomRoll = pow(pow(Double.random(), Double.random()), 10).roundTo(places: 2)
//    opposingPlayer = getRandomConditionThenPlayer()
//    opposingPlayer = getLastPlayer()
//    opposingPlayer = getNextPlayer()
    opposingPlayer = getRandomPlayer()
//    opposingPlayer = getNextPlayer()
//    opposingPlayer = getLosingPlayer()
    
    var opposingRoll = Double.random().roundTo(places: 2)
    if let roll = players[opposingPlayer], roll > 1.0 { opposingRoll *= roll }
    //  let randomThreshold = pow(pow(Double.random(), Double.random()), 10).roundTo(places: 2)
    
    winningPlayer = (playerRoll > opposingRoll ? chosenPlayer : opposingPlayer)!
    losingPlayer = (playerRoll > opposingRoll ? opposingPlayer : chosenPlayer)!
    
    guard let _winningPlayerScore = score[winningPlayer] else { return }
    let winnningPlayerScore = (_winningPlayerScore.roundTo(places: 2) +
      playerRoll.roundTo(places: 2)
//      opposingRoll.roundTo(places: 2)
//      (playerRoll - opposingRoll).roundTo(places: 2)
//      Double.random()
    )
    score[winningPlayer] = winnningPlayerScore.roundTo(places: 2)
    
    guard let _losingPlayerScore = score[losingPlayer] else { return }
    let losingPlayerScore = (_losingPlayerScore.roundTo(places: 2) -
//      opposingRoll.roundTo(places: 2)
        playerRoll.roundTo(places: 2)
//      (playerRoll - opposingRoll).roundTo(places: 2)
//      Double.random()
    )
    score[losingPlayer] = losingPlayerScore.roundTo(places: 2)
    
//    print("turn \(currentTurn) \(chosenPlayer!) rolled \(randomRoll) against \(opposingPlayer) to pass \(randomThreshold)")
    
    globalSum = 0
    score.forEach {
      if let score = score[$0.key] {
        globalSum += score.roundTo(places: 2)
      }
//      print("\($0.key): \($0.value) ", terminator:"")
    }
    
//    print("")
//    print("total sum is \(abs(globalSum.roundTo(places: 2)))")
    
    currentTurn += 1
  }
  
  func getWinningPlayer() -> String {
    return score.max { (first, second) -> Bool in
      return first.value > second.value
    }!.key
  }
  func getLosingPlayer() -> String {
    return score.min { (first, second) -> Bool in
      return first.value > second.value
    }!.key
  }
  func getLastPlayer() -> String {
    return Array(self.players)[(max(currentTurn - 1, 0)) % players.count].key
  }
  func getNextPlayer() -> String {
    let players = Array(self.players)
    return players[(currentTurn + 1) % players.count].key
  }
  func getRandomPlayer() -> String {
    let players = Array(self.players)
    return players[Int(arc4random_uniform(UInt32(players.count)) + 1) % players.count].key
  }
  func getRandomPlayerExclusive(player: String) -> String {
    var opposingPlayer = getRandomPlayer()
    while opposingPlayer == player {
      opposingPlayer = getRandomPlayer() }
    return opposingPlayer
  }
  
  let queue = DispatchQueue.global(qos: .background)
  
  func startGame(speed: Double) {
    // initalize
    resetScore()
    chosenPlayer = getRandomPlayer()
    opposingPlayer = getRandomPlayer()
    // start game
    Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { [weak self] (timer) in
        self?.queue.async { [weak self] in
        self?.roll()
      }
    }
  }
  
  func resetScore() {
    players.forEach { score[$0.key] = 0.0 }
//    players.forEach { score[$0.key] = Double.random() }
  }
}

extension UIColor {
  static func randomColor() -> UIColor {
    return UIColor(red:   min(.random(), 0.75),
                   green: min(.random(), 0.75),
                   blue:  min(.random(), 0.75),
                   alpha: 1.0)
  }
}

extension CGFloat {
  static func random() -> CGFloat {
    return CGFloat(arc4random_uniform(100)) / 100
  }
}

extension Double {
  static func random() -> Double {
    return Double(arc4random_uniform(100)) / 100
  }
  /// Rounds the double to decimal places value
  func roundTo(places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}
