//
//  Item.swift
//  DungeonGenerator
//
//  Created by Kyle Peterson on 11/11/24.
//

class Item {
    var name: String
    var symbol: Character

    init(name: String, symbol: Character) {
        self.name = name
        self.symbol = symbol
    }
}

// Subclasses for different item types
class Loot: Item {
    var value: Int

    init(name: String, value: Int) {
        self.value = value
        super.init(name: name, symbol: "$")
    }
}

class Consumable: Item {
    var effect: String

    init(name: String, effect: String) {
        self.effect = effect
        super.init(name: name, symbol: "!")
    }
}
