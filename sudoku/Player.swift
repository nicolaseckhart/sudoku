//
//  Player.swift
//  sudoku
//
//  Created by Nicolas Eckhart on 21.11.18.
//  Copyright © 2018 Nicolas Eckhart. All rights reserved.
//

import Foundation
import UIKit

class Player {
    private var name: String
    private var clock: Stopwatch
    private var selection: Int?
    
    init(name: String, clockLabel: UILabel) {
        self.name = name
        clock = Stopwatch(label: clockLabel)
    }
    
    // name
    
    func getName() -> String {
        return name
    }
    
    // clock
    
    func startClock() {
        clock.start()
    }
    
    func stopClock() {
        clock.stop()
    }
    
    func resetClock() {
        clock.reset()
    }
    
    func getElapsedTime() -> Int {
        return clock.getElapsedTime()
    }
    
    func modifyElapsedTime(modifier: Int) {
        clock.addTime(seconds: modifier)
    }
   
    // selection
    
    func getSelection() -> Int? {
        return selection
    }
    
    func madeSelection() -> Bool {
        return (selection != nil)
    }
    
    func selectField(fieldNumber: Int?) {
        selection = fieldNumber
    }
    
    func clearSelection() {
        selection = nil
    }
    
    func isSelectionPossible(fieldNumber: Int) -> Bool {
        return (selection == nil || selection == fieldNumber)
    }
}
