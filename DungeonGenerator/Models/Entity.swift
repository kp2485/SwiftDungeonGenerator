//
//  Entity.swift
//  DungeonGenerator
//
//  Created by Kyle Peterson on 11/11/24.
//

class Entity {
    var name: String
    var x: Int
    var y: Int
    var symbol: Character

    init(name: String, x: Int, y: Int, symbol: Character) {
        self.name = name
        self.x = x
        self.y = y
        self.symbol = symbol
    }
}

// Player subclass
class Player: Entity {
    init(x: Int, y: Int) {
        super.init(name: "Player", x: x, y: y, symbol: "@")
    }
}

// Enemy subclass
class Enemy: Entity {
    var enemyType: String

    init(enemyType: String, x: Int, y: Int) {
        self.enemyType = enemyType
        super.init(name: enemyType, x: x, y: y, symbol: "E")
    }
}

// NPC subclass
class NPC: Entity {
    var dialogue: String

    init(name: String, x: Int, y: Int, dialogue: String) {
        self.dialogue = dialogue
        super.init(name: name, x: x, y: y, symbol: "N")
    }
}
