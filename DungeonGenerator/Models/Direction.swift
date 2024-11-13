//
//  Direction.swift
//  DungeonGenerator
//
//  Created by Kyle Peterson on 11/13/24.
//


enum Direction: CaseIterable {
    case north, south, east, west
    
    /// Returns the opposite direction.
    var opposite: Direction {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .east:
            return .west
        case .west:
            return .east
        }
    }
}
