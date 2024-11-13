//
//  Tile.swift
//  DungeonGenerator
//
//  Created by Kyle Peterson on 11/11/24.
//


import Foundation

// Base Tile class
class Tile {
    var x: Int
    var y: Int
    var passable: Bool
    var symbol: Character

    init(x: Int, y: Int, passable: Bool, symbol: Character) {
        self.x = x
        self.y = y
        self.passable = passable
        self.symbol = symbol
    }
}

// Subclasses for different tile types
class FloorTile: Tile {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, passable: true, symbol: ".")
    }
}

class WallTile: Tile {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, passable: false, symbol: "#")
    }
}

class DoorTile: Tile {
    var isLocked: Bool

    init(x: Int, y: Int, isLocked: Bool = false) {
        self.isLocked = isLocked
        let symbol: Character = isLocked ? "L" : "D"
        super.init(x: x, y: y, passable: !isLocked, symbol: symbol)
    }
}

class TrapTile: Tile {
    var trapType: String

    init(x: Int, y: Int, trapType: String) {
        self.trapType = trapType
        super.init(x: x, y: y, passable: true, symbol: "^")
    }
}
