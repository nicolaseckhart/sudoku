//
//  ViewController.swift
//  sudoku
//
//  Created by Nicolas Eckhart on 21.11.18.
//  Copyright © 2018 Nicolas Eckhart. All rights reserved.
//

import UIKit
import Toast_Swift

class ViewController: UIViewController {
    
    // ============================================
    // =             OUTLET VARIABLES             =
    // ============================================
    
    // All the field buttons are here starting at tag 0 (top-left) until tag 80 (buttom-right)
    @IBOutlet var fieldButtons: [UIButton]!
    
    // The two labels that show the elapsed time for each player
    @IBOutlet weak var p1Label: UILabel!
    @IBOutlet weak var p2Label: UILabel!
    
    
    // ============================================
    // =              GAME VARIABLES              =
    // ============================================
    
    // Initialize a new board with starting values and solutions
    var board: Board = Board(values: [
            5, 3, 4, 6, 7, 8, 9, 1, 2,
            6, 7, 2, 1, 9, 5, 0, 4, 8,
            1, 9, 8, 3, 4, 2, 5, 6, 7,
            8, 5, 9, 7, 6, 1, 4, 2, 3,
            4, 2, 6, 0, 5, 3, 7, 9, 1,
            7, 1, 3, 9, 2, 4, 8, 5, 6,
            9, 6, 1, 5, 3, 7, 2, 8, 4,
            2, 8, 0, 4, 1, 0, 6, 0, 5,
            3, 4, 5, 2, 8, 6, 1, 7, 9
        ], solutions: [
            5, 3, 4, 6, 7, 8, 9, 1, 2,
            6, 7, 2, 1, 9, 5, 3, 4, 8,
            1, 9, 8, 3, 4, 2, 5, 6, 7,
            8, 5, 9, 7, 6, 1, 4, 2, 3,
            4, 2, 6, 8, 5, 3, 7, 9, 1,
            7, 1, 3, 9, 2, 4, 8, 5, 6,
            9, 6, 1, 5, 3, 7, 2, 8, 4,
            2, 8, 7, 4, 1, 9, 6, 3, 5,
            3, 4, 5, 2, 8, 6, 1, 7, 9
        ]
    )
    var gameStarted: Bool = false
    var players: [Player] = []
    var active: Int = 0
    
    // ============================================
    // =              OUTLET ACTIONS              =
    // ============================================

    // This function is called for the action button
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if (!gameStarted) {
            // If not yet startet, begin with player 1
            players[active].startClock()
            gameStarted = true
            sender.setTitle("End Turn", for: .normal)
        } else if (players[active].madeSelection()) {
            // Only end turn if player input a number
            players[active].stopClock()
            
            // Check player input and fetch time bonus / punishment
            let playerSelection = players[active].getSelection()!
            let result = board.checkChanges(fieldNumber: playerSelection)
            
            // Update the fieldButton title in case the field value was reset
            updateButtonTitles()
            
            // Display the message about the result of the board check and apply time modifier to player clock
            displayTurnMessage(timeModifier: result)
            players[active].modifyElapsedTime(modifier: result)
            
            // If the board was solved
            if (board.isSolved()) {
                displayWinnerMessage()
                resetGame()
                sender.setTitle("Start Game", for: .normal)
                return
            }
            
            // Clear the selection and switch players
            players[active].clearSelection()
            switchActivePlayer()
            
            // Start next players clock
            players[active].startClock()
        }
    }
    
    // This function is called for each of the 81 field buttons
    @IBAction func fieldPressed(_ sender: UIButton) {
        // Skip if game has not started, board is locked or player has already selected another field
        if (gameStarted && !board.fields[sender.tag].locked && players[active].isSelectionPossible(fieldNumber: sender.tag)) {
            updateField(fieldButton: sender)
            players[active].selectField(fieldNumber: sender.tag)
        }
    }
    
    // ============================================
    // =             VIEW INITIALIZER             =
    // ============================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the initial field values onto the corresponding buttons
        updateButtonTitles()
        
        // Initialize the two players
        players.append(Player(name: "Player 1", clockLabel: p1Label))
        players.append(Player(name: "Player 2", clockLabel: p2Label))
    }
    
    // ============================================
    // =             HELPER FUNCTIONS             =
    // ============================================
    
    func updateButtonTitles() {
        for fieldButton in fieldButtons {
            if (board.fields[fieldButton.tag].value != 0) {
                fieldButton.setTitle(board.fields[fieldButton.tag].getLabel(), for: .normal)
                fieldButton.setTitleColor(UIColor.gray, for: .normal)
            } else {
                fieldButton.setTitle("", for: .normal)
            }
        }
    }
    
    func updateField(fieldButton: UIButton) {
        let fieldNumber = fieldButton.tag
        board.fields[fieldNumber].increment()
        fieldButton.setTitle(board.fields[fieldNumber].getLabel(), for: .normal)
        if (board.fields[fieldNumber].isSolved()) {
            fieldButton.setTitleColor(UIColor.gray, for: .normal)
            board.fields[fieldNumber].lock()
        }
    }
    
    func switchActivePlayer() {
        if (active == 0) {
            active = 1
        } else {
            active = 0
        }
    }
    
    func displayWinnerMessage() {
        let p1Time = players[0].getElapsedTime()
        let p2Time = players[1].getElapsedTime()
        
        var message: String
        if (p1Time > p2Time) {
            message = "\(players[1].getName()) wins by \(p1Time - p2Time)s!"
        } else if (p1Time < p2Time) {
            message = "\(players[0].getName()) wins by \(p2Time - p1Time)s!"
        } else {
            message = "It's a tie!"
        }
        self.view.makeToast(message, duration: 5.0, position: .top)
    }
    
    func displayTurnMessage(timeModifier: Int) {
        let message: String
        if (timeModifier > 0) {
            message = "Incorrect! \(players[active].getName())'s time is increased by \(timeModifier)s"
        } else if (timeModifier < 0) {
            message = "Correct! \(players[active].getName())'s time is reduced by \(timeModifier)s"
        } else {
            message = "Correct!"
        }
        self.view.makeToast(message)
    }
    
    func resetGame() {
        for player in players {
            player.clearSelection()
            player.resetClock()
        }
        
        gameStarted = false
        board = Board(values: [
                5, 3, 4, 6, 7, 8, 9, 1, 2,
                6, 7, 2, 1, 9, 5, 0, 4, 8,
                1, 9, 8, 3, 4, 2, 5, 6, 7,
                8, 5, 9, 7, 6, 1, 4, 2, 3,
                4, 2, 6, 0, 5, 3, 7, 9, 1,
                7, 1, 3, 9, 2, 4, 8, 5, 6,
                9, 6, 1, 5, 3, 7, 2, 8, 4,
                2, 8, 0, 4, 1, 0, 6, 0, 5,
                3, 4, 5, 2, 8, 6, 1, 7, 9
            ], solutions: [
                5, 3, 4, 6, 7, 8, 9, 1, 2,
                6, 7, 2, 1, 9, 5, 3, 4, 8,
                1, 9, 8, 3, 4, 2, 5, 6, 7,
                8, 5, 9, 7, 6, 1, 4, 2, 3,
                4, 2, 6, 8, 5, 3, 7, 9, 1,
                7, 1, 3, 9, 2, 4, 8, 5, 6,
                9, 6, 1, 5, 3, 7, 2, 8, 4,
                2, 8, 7, 4, 1, 9, 6, 3, 5,
                3, 4, 5, 2, 8, 6, 1, 7, 9
            ]
        )
        updateButtonTitles()
    }
}
