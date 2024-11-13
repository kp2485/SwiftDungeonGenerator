//
//  Room.swift
//  DungeonGenerator
//
//  Created by Kyle Peterson on 11/11/24.
//

class Room {
    var tiles: [Tile] = []
    var entities: [Entity] = []
    var items: [Item] = []

    init(tiles: [Tile]) {
        self.tiles = tiles
    }

    func addEntity(_ entity: Entity) {
        entities.append(entity)
    }

    func addItem(_ item: Item) {
        items.append(item)
    }
}
