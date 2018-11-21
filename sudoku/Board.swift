//
//  Board.swift
//  sudoku
//
//  Created by Nicolas Eckhart on 21.11.18.
//  Copyright © 2018 Nicolas Eckhart. All rights reserved.
//

import Foundation

class Board {
    var fields: [Field]
    
    init(values: [Int], solutions: [Int]) {
        fields = []
        for i in 0...80 {
            fields.append(Field(startValue: values[i], solution: solutions[i]))
        }
    }
    
    func isSolved() -> Bool {
        for field in fields {
            if !field.isSolved() {
                return false
            }
        }
        return true
    }
    
    func checkChanges(fieldNumber: Int) -> Int {
        // Return +3 seconds as punishment
        if (!fields[fieldNumber].isSolved()) {
            fields[fieldNumber].value = 0
            return 3
        }
        
        // Map the values and solutions to 2d for ease of use
        // var fieldValues: [[Int]] = mapTo2dArray(array: fields.map { $0.value })
        // var fieldSolutions: [[Int]] = mapTo2dArray(array: fields.map { $0.solution })
        
        // TODO: Check if row or col or box full and give a bonus to the player
        
        return 0
    }
    
    private func mapTo2dArray(array: [Int]) -> [[Int]] {
        var mappedArray: [[Int]] = []
        var baseIndex = 0
        
        for i in Range(0...8) {
            mappedArray.append([])
            for _ in Range(0...8) {
                mappedArray[i].append(array[baseIndex])
                baseIndex += 1
            }
        }
        
        return mappedArray
    }
}
