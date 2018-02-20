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
}

class PatternSequencer {
    
    private var patterns = [Pattern]()
    
    func load() {
        // load patterns from file
        // @TODO: refactor, remove nesting
        if let path = Bundle.main.path(forResource: "AllPatterns", ofType: "txt") {
            do {
                
                let data = try String(contentsOfFile: path, encoding: .utf8)
                
                let lines = data.components(separatedBy: .newlines)
                self.patterns = self.parsePatternsFile(lines: lines)
            } catch {
                print(error)
                assert(false)
            }
        } else {
            assert(false) // FILE NOT FOUND
        }
    }
    
    func getPattern() -> Pattern {
        return self.patterns[0] // @TODO, actually return patterns
    }
    
    private func parsePatternsFile(lines: [String]) -> [Pattern] {
        var result = [Pattern]()
        
        var buffer = [Row]()
        for line in lines.reversed() {
            let (parseResult, parseValue) = self.parseLine(line)
            if parseResult == .failure { assert(false) }
            
            switch parseValue {
            case .blank: continue
            case .invalid: assert(false)
            case let .row(row):
                buffer.append(row)
            case let .header(difficulty):
                let pattern = Pattern(rows: buffer, difficulty: difficulty)
                result.append(pattern)
                buffer.removeAll()
            }
        }
        
        return result
    }
    
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
}
