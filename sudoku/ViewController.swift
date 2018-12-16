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
    
    // Action Button to start game and end turns
    @IBOutlet var actionButton: UIButton!
    
    // Alternative Button to pause and reset game
    @IBOutlet weak var altButton: UIButton!
    
    // ============================================
    // =              GAME VARIABLES              =
    // ============================================
    
    // Initialize a new board with starting values and solutions
    var board: Board = Board()
    var gameStarted: Bool = false
    var gamePaused: Bool = false
    var players: [Player] = []
    var active: Int = 0
    
    // ============================================
    // =              OUTLET ACTIONS              =
    // ============================================
    
    // This function is called for the action button
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if (!gameStarted) {
            // If not yet startet, begin with player 1
            gameStarted = true
            sender.setTitle("End Turn", for: .normal)
            players[active].startClock()
        } else if (players[active].madeSelection()) {
            // Only end turn if player input a number
            players[active].stopClock()
            
            gamePaused = true
            
            // Check player input and fetch time bonus / punishment
            let playerSelection = players[active].getSelection()!
            let result = board.checkChanges(fieldNumber: playerSelection)
            
            if (board.getField(fieldNumber: playerSelection).isSolved()) {
                fieldButtons[playerSelection].setTitleColor(UIColor.gray, for: .normal)
                board.getField(fieldNumber: playerSelection).lock()
            }
            
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
            
            // Indicate change of button function after turn ended
            sender.setTitle("Start Turn \(players[active].getName())", for: .normal)
        } else if (gamePaused) {
            // If game is paused, start next turn
            gamePaused = false
            sender.setTitle("End Turn", for: .normal)
            
            // show Sudoku board again
            updateButtonTitles()
            
            // Start next players clock
            players[active].startClock()
        }
    }
    
    // This function is called for the alternative Button on tap
    @IBAction func altButtonPressed(_ sender: UIButton) {
        self.view.makeToast("Long press button to reset game.")
    }
    
    // This function is called for the alternative Button on 2 second long press
    @IBAction func handleGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began
        {
            self.view.makeToast("Game Reset")
            resetGame()
        }
    }
    
    // This function is called for each of the 81 field buttons
    @IBAction func fieldPressed(_ sender: UIButton) {
        // Skip if game has not started, board is locked or player has already selected another field
        if (gameStarted && !board.getField(fieldNumber: sender.tag).isLocked() && players[active].isSelectionPossible(fieldNumber: sender.tag)) {
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
        players.append(Player(name: "P1", clockLabel: p1Label))
        players.append(Player(name: "P2", clockLabel: p2Label))
    }
    
    // ============================================
    // =             HELPER FUNCTIONS             =
    // ============================================
    
    func updateButtonTitles() {
        for fieldButton in fieldButtons {
            // Add sudoku values to board if game is not paused
            if(!gamePaused){
                if (board.getField(fieldNumber: fieldButton.tag).getValue() != 0) {
                    fieldButton.setTitle(board.getField(fieldNumber: fieldButton.tag).getLabel(), for: .normal)
                    fieldButton.setTitleColor(UIColor.gray, for: .normal)
                } else {
                    fieldButton.setTitle("", for: .normal)
                }
            }
            // If paused, hide input to avoid cheating
            else {
                fieldButton.setTitle("?", for: .normal)
                fieldButton.setTitleColor(UIColor.gray, for: .normal)
            }
        }
    }
    
    func updateField(fieldButton: UIButton) {
        let fieldNumber = fieldButton.tag
        board.getField(fieldNumber: fieldNumber).increment()
        fieldButton.setTitle(board.getField(fieldNumber: fieldNumber).getLabel(), for: .normal)
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
        players[active].stopClock()
        gameStarted = false
        gamePaused = false
        board = Board()
        updateButtonTitles()
        actionButton.setTitle("Start Game", for: .normal)
    }
}

