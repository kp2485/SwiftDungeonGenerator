//
//  Cell.swift
//  DungeonGenerator
//
//  Created by Kyle Peterson on 11/13/24.
//


struct Cell {
    let position: Position
    var walls: [Direction: Bool] // true means the wall exists
    var visited: Bool
    
    /// Initializes a new cell with all walls intact and marked as unvisited.
    init(x: Int, y: Int) {
        self.position = Position(x: x, y: y)
        self.walls = [
            .north: true,
            .south: true,
            .east: true,
            .west: true
        ]
        self.visited = false
    }
}
