//
//  Field.swift
//  sudoku
//
//  Created by Nicolas Eckhart on 21.11.18.
//  Copyright © 2018 Nicolas Eckhart. All rights reserved.
//

import Foundation

class Field {
    private var value: Int
    private var solution: Int
    private var locked: Bool
    
    init(startValue: Int, solution: Int) {
        self.value = startValue
        self.solution = solution
        
        // If there is a start value, lock the field
        self.locked = (startValue != 0)
    }
    
    func isSolved() -> Bool {
        return (value == solution)
    }
    
    func increment() {
        if (value + 1 > 9) {
            value = 1
        } else {
            value += 1
        }
    }
    
    func lock() {
        locked = true
    }
    
    func unlock() {
        locked = false
    }
    
    func isLocked() -> Bool {
        return locked
    }
    
    func getLabel() -> String {
        return String(value)
    }
    
    func getValue() -> Int {
        return value
    }
    
    func setValue(value: Int) {
        self.value = value
    }
    
    func getSolution() -> Int {
        return solution
    }
}
