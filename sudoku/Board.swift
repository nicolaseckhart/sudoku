//
//  Board.swift
//  sudoku
//
//  Created by Nicolas Eckhart on 21.11.18.
//  Copyright © 2018 Nicolas Eckhart. All rights reserved.
//

import Foundation
import AEXML

class Board {
    private var fields: [Field]
    
    init() {
        // Read and parse XML document containing the sudoku boards
        let xmlPath = Bundle.main.path(forResource: "sudoku", ofType: "xml")!
        let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath))
        var xmlData: AEXMLDocument? = nil
        
        do {
            xmlData = try AEXMLDocument(xml: data!)
        } catch {
            print(error)
        }
        
        // Select a random board and initialize the fields with the values and solutions from it
        let boardIndex = Int.random(in: 0 ..< 101)
        let values = Array(xmlData!.root.children[boardIndex]["values"].attributes["data"]!).map { Int(String($0))! }
        let solutions = Array(xmlData!.root.children[boardIndex]["solutions"].attributes["data"]!).map { Int(String($0))! }
        fields = (0...80).map { Field(startValue: values[$0], solution: solutions[$0]) }
    }
    
    func isSolved() -> Bool {
        for field in fields {
            if !field.isSolved() {
                return false
            }
        }
        return true
    }
    
    func isRowSolved(rowIndex: Int) -> Bool {
        for i in (0...8) {
            if (mapTo2dArray(array: fields.map { $0.getValue() })[rowIndex][i] != mapTo2dArray(array: fields.map { $0.getSolution() })[rowIndex][i]) {
                return false
            }
        }
        return true
    }
    
    func isColSolved(colIndex: Int) -> Bool {
        for i in (0...8) {
            if (mapTo2dArray(array: fields.map { $0.getValue() })[i][colIndex] != mapTo2dArray(array: fields.map { $0.getSolution() })[i][colIndex]) {
                return false
            }
        }
        return true
    }
    
    func getField(fieldNumber: Int) -> Field {
        return fields[fieldNumber]
    }
    
    func checkChanges(fieldNumber: Int) -> Int {
        // Return +3 seconds as punishment
        if (!fields[fieldNumber].isSolved()) {
            fields[fieldNumber].setValue(value: 0)
            return 3
        }
        
        var result = 0
        
        // Add -5 for bonus if a row or col has been solved
        let fieldNumber2d: (Int, Int) = mapIndexTo2dIndex(index: fieldNumber)
        if (isRowSolved(rowIndex: fieldNumber2d.0)) {
            result -= 5
        }
        if (isColSolved(colIndex: fieldNumber2d.1)) {
            result -= 5
        }
        
        return result
    }
    
    private func mapIndexTo2dIndex(index: Int) -> (Int, Int) {
        var position: (Int, Int)
        position.0 = index / 9
        position.1 = index % 9
        return position
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
