//
//  PatternSequencer.swift
//  KittyKatch
//
//  Created by Nathan Hunt on 2/19/18.
//  Copyright © 2018 Team BeeDream. All rights reserved.
//

import Foundation

struct Pickup {
    let type: PickupType
    let lane: Lane
}

struct Row {
    var pickups: [Pickup]
}

protocol PatternSequencer {
    func getSequence(difficulty: Difficulty, pickupCount: Int) -> [Row]
}

class DefaultPatternSequencer {
    private var patterns: [Difficulty: [Pattern]]!
    private var maxPickupsPerPattern: Int = 0
    
    init(filePath: String) {
        assert(!filePath.isEmpty)
        
        // @NOTE: self.patterns is a dictionary
        //        where every key needs to be initialized
        // @FIXME: find better way to do this automatically
        self.patterns = [Difficulty: [Pattern]]()
        self.patterns[.starter] = [Pattern]()
        self.patterns[.easy] = [Pattern]()
        self.patterns[.medium] = [Pattern]()
        self.patterns[.hard] = [Pattern]()
        self.patterns[.veryHard] = [Pattern]()
        
        self.loadData(filePath)
    }
}

// MARK: - Protocol Completion
extension DefaultPatternSequencer: PatternSequencer {
    private struct Pattern {
        var rows: [Row]
        var difficulty: Difficulty
        var pickupCount: Int
    }
    
    private enum LineType {
        case header(Difficulty)
        case row(Row)
        case blank
        case invalid
    }
}

// MARK: - Public Functions
extension DefaultPatternSequencer {
    func getSequence(difficulty: Difficulty, pickupCount: Int) -> [Row] {
        var remainingPickups = pickupCount
        var sequence = [Row]()
        
        while remainingPickups > 0 {
            let pickupCount = Math.randInt(min: 1, max: self.maxPickupsPerPattern)
            let pattern = self.findPattern(difficulty: difficulty, maxPickupCount: pickupCount)
            remainingPickups -= pattern.pickupCount
            sequence.append(contentsOf: pattern.rows)
        }
        
        return sequence
    }
}

// MARK: - Loading Data
extension DefaultPatternSequencer {
    private func loadData(_ path: String) {
        let data = try! String(contentsOfFile: path, encoding: .utf8)
        let lines = data.components(separatedBy: .newlines)
        let patterns = self.parsePatternsFile(lines: lines)
        for pattern in patterns {
            self.patterns[pattern.difficulty]?.append(pattern)
            if self.maxPickupsPerPattern < pattern.pickupCount {
                self.maxPickupsPerPattern = pattern.pickupCount
            }
        }
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
            switch self.parseLine(line) {
            case .blank:
                continue // ignore blank lines
                
            case .invalid:
                assert(false) // fail on invalid lines
                
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
    
    // @TODO: give option to flip
    private func parseLine(_ line: String, flip: Bool = false) -> LineType {
        let characters = Array(line)
        
        // case for blank line
        if characters.isEmpty {
            return .blank
        }
        
        // case for header
        if characters.count == 2 && characters[0] == "D" {
            let intValue = Int(String(characters[1]))
            let difficulty = Difficulty(rawValue: intValue!)
            return .header(difficulty!)
        }
        
        // case for row
        if characters.count == 3 {
            var pickups = [Pickup]()
            for (index, char) in characters.enumerated() {
                switch char {
                case ".":
                    pickups.append(Pickup(type: .none, lane: self.indexToLane(index)))
                case "+":
                    pickups.append(Pickup(type: .good, lane: self.indexToLane(index)))
                case "-":
                    pickups.append(Pickup(type: .bad, lane: self.indexToLane(index)))
                default:
                    return .invalid
                }
            }
            if flip { pickups.reverse() }
            let row = Row(pickups: pickups)
            return .row(row)
        }
        
        // failure
        assert(false)
    }
    
    private func indexToLane(_ index: Int) -> Lane {
        assert(index >= 0 && index < Lane.count)
        
        return Lane(rawValue: index - 1)! // @TODO: relocate
    }
    
    private func countPickups(row: Row, type: PickupType) -> Int {
        var count = 0
        for p in row.pickups {
            if p.type == type { count += 1}
        }
        return count
    }
}
