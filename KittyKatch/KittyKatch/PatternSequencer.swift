//
//  PatternSequencer.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/19/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation

enum Pickup { // @TODO: rename
    case good
    case bad
    case none
}

enum Result {
    case success
    case failure
}

enum Difficulty: Int {
    case starter    = 0
    case easy       = 1
    case medium     = 2
    case hard       = 3
    case veryHard   = 4
}

enum LineType { // @TODO: better name
    case header(Difficulty)
    case row(Row)
    case blank
    case invalid
}

struct PickupData { // @TODO: rename
    let pickup: Pickup
    let lane: Lane
}

struct Row {
    var pickups: [PickupData]
}

struct Pattern {
    var rows: [Row]
    var difficulty: Difficulty
    var pickupCount: Int
}

class PatternSequencer {
    
    private var patterns: [Difficulty: [Pattern]]!
    private var maxPickupsPerPattern: Int = 0
    
    init() {
        self.patterns = [Difficulty: [Pattern]]()
        self.patterns[.starter] = [Pattern]()
        self.patterns[.easy] = [Pattern]()
        self.patterns[.medium] = [Pattern]()
        self.patterns[.hard] = [Pattern]()
        self.patterns[.veryHard] = [Pattern]()
        // @FIXME, find better way to do this
    }
    
    func load() {
        // load patterns from file
        // @TODO: refactor, remove nesting
        if let path = Bundle.main.path(forResource: "AllPatterns", ofType: "txt") {
            do {
                
                let data = try String(contentsOfFile: path, encoding: .utf8)
                
                let lines = data.components(separatedBy: .newlines)
                let patterns = self.parsePatternsFile(lines: lines)
                for pattern in patterns {
                    self.patterns[pattern.difficulty]?.append(pattern)
                    if self.maxPickupsPerPattern < pattern.pickupCount {
                        self.maxPickupsPerPattern = pattern.pickupCount
                    }
                }
                
            } catch {
                print(error)
                assert(false)
            }
        } else {
            assert(false) // FILE NOT FOUND
        }
    }
    
    func getSequence(difficulty: Difficulty, pickupCount: Int) -> [Row] {
        var remainingPickups = pickupCount
        var sequence = [Row]()
        
        while remainingPickups > 0 {
            let pickupCount = self.randInt(min: 1, max: self.maxPickupsPerPattern)
            let pattern = self.findPattern(difficulty: difficulty, maxPickupCount: pickupCount)
            remainingPickups -= pattern.pickupCount
            sequence.append(contentsOf: pattern.rows)
        }
        
        return sequence
    }
    
    // @TODO: move, fix
    func randInt(min: Int, max: Int) -> Int {
        let range = max - min
        let randValue = Int(arc4random_uniform(UInt32(range)))
        return Int(randValue + min)
    }
    
    private func findPattern(difficulty: Difficulty, maxPickupCount: Int) -> Pattern {
        var currentDifficulty = difficulty.rawValue
        var lookingForCount = maxPickupCount
        var looking = true
        while looking {
            let patternSet = self.patterns[Difficulty(rawValue: currentDifficulty)!]
            for pattern in patternSet! {
                if pattern.pickupCount == lookingForCount {
                    //print("looking for D", difficulty, " C", maxPickupCount)
                    //print("found D", Difficulty(rawValue: currentDifficulty)!, " C", lookingForCount)
                    return pattern
                }
            }
            
            // reduce number looking for
            if lookingForCount > 0 {
                lookingForCount -= 1
                //print("reducing look count")
            } else {
                lookingForCount = maxPickupCount
                currentDifficulty -= 1 // bug
                //print("reducing difficulty")
            }
            
            // exit loop
            if currentDifficulty == -1 {
                looking = false // ERROR
            }
        }
        
        assert(false) // failed to find pattern
    }
    
    private func parsePatternsFile(lines: [String]) -> [Pattern] {
        var result = [Pattern]()
        
        var buffer = [Row]()
        var bufferPickupCount = 0
        for line in lines.reversed() {
            let (parseResult, parseValue) = self.parseLine(line)
            if parseResult == .failure { assert(false) }
            
            switch parseValue {
            case .blank: continue
            case .invalid: assert(false)
            case let .row(row):
                buffer.append(row)
                bufferPickupCount += self.countPickups(row: row, type: .good)
            case let .header(difficulty):
                let pattern = Pattern(rows: buffer, difficulty: difficulty, pickupCount: bufferPickupCount)
                result.append(pattern)
                buffer.removeAll()
                bufferPickupCount = 0
            }
        }
        
        return result
    }
    
    // @TODO: give option to reverse
    private func parseLine(_ line: String) -> (Result, LineType) {
        let characters = Array(line)
        
        // case for blank line
        if characters.isEmpty {
            return (.success, .blank)
        }
        
        // case for header
        if characters.count == 2 && characters[0] == "D" {
            let intValue = Int(String(characters[1]))
            let difficulty = Difficulty(rawValue: intValue!)
            return (.success, .header(difficulty!))
        }
        
        // case for row
        if characters.count == 3 {
            var pickups = [PickupData]()
            for (index, char) in characters.enumerated() {
                switch char {
                case ".":
                    pickups.append(PickupData(pickup: .none, lane: self.indexToLane(index)))
                case "+":
                    pickups.append(PickupData(pickup: .good, lane: self.indexToLane(index)))
                case "-":
                    pickups.append(PickupData(pickup: .bad, lane: self.indexToLane(index)))
                default:
                    return (.failure, .invalid)
                }
            }
            let row = Row(pickups: pickups)
            return (.success, .row(row))
        }
        
        // failure
        return (.failure, .invalid)
    }
    
    private func indexToLane(_ index: Int) -> Lane {
        assert(index >= 0 && index < Lane.count)
        
        return Lane(rawValue: index - 1)! // @TODO: relocate
    }
    
    private func countPickups(row: Row, type: Pickup) -> Int {
        var count = 0
        for p in row.pickups {
            if p.pickup == type { count += 1}
        }
        return count
    }
}
