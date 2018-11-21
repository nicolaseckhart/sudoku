//
//  Stopwatch.swift
//  sudoku
//
//  Created by Nicolas Eckhart on 21.11.18.
//  Copyright © 2018 Nicolas Eckhart. All rights reserved.
//

import Foundation
import UIKit

class Stopwatch {
    private var elapsedTime: Int
    private var timer: Timer?
    private var label: UILabel
    
    init(label: UILabel) {
        self.label = label
        elapsedTime = 0
        timer = nil
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(Stopwatch.tick)), userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    func reset() {
        elapsedTime = 0
        writeTimeToLabel()
    }
    
    func addTime(seconds: Int) {
        if (elapsedTime + seconds < 0) {
            elapsedTime = 0
        } else {
            elapsedTime += seconds
        }
        writeTimeToLabel()
    }
    
    func getElapsedTime() -> Int {
        return elapsedTime
    }
    
    @objc private func tick() {
        elapsedTime += 1
        writeTimeToLabel()
    }
    
    private func writeTimeToLabel() {
        label.text = "\(formattedTime())"
    }
    
    private func formattedTime() -> String {
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
