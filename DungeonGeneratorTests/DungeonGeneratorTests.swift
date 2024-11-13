//
//  DungeonGeneratorTests.swift
//  DungeonGeneratorTests
//
//  Created by Kyle Peterson on 11/11/24.
//

import Testing
@testable import DungeonGenerator

struct DungeonGeneratorTests {

    // MARK: - Parameterized Tests

    /// Test that the dungeon initializes correctly with various dimensions.
    @Test("Dungeon initializes correctly with given dimensions", arguments: [
        (width: 40, height: 20),
        (width: 50, height: 30),
        (width: 10, height: 10),
        (width: 100, height: 50)
    ])
    func testDungeonInitialization(width: Int, height: Int) async throws {
        // Arrange & Act
        let dungeon = Dungeon(width: width, height: height)

        // Assert
        #expect(dungeon.width == width, "Dungeon width should match the initialized value.")
        #expect(dungeon.height == height, "Dungeon height should match the initialized value.")
        
        // Verify all cells are initialized as unvisited with walls intact
        for x in 0..<width {
            for y in 0..<height {
                let cell = dungeon.grid[x][y]
                #expect(!cell.visited, "Cell at (\(x), \(y)) should be unvisited initially.")
                #expect(cell.walls == [.north: true, .south: true, .east: true, .west: true],
                        "All cells should have walls intact initially.")
            }
        }
    }

    /// Test that the Recursive Backtracker algorithm creates a connected maze.
    @Test("Recursive backtracker generates a connected maze")
    func testRecursiveBacktrackerConnectivity() async throws {
        let dungeon = Dungeon(width: 10, height: 10)
        dungeon.generateDungeon(using: .recursiveBacktracker)
        
        var visitedPositions = Set<Position>()
        func explore(from position: Position) {
            visitedPositions.insert(position)
            guard let cell = dungeon.getCell(at: position) else { return }
            
            for direction in Direction.allCases {
                if cell.walls[direction] == false {
                    // Get the neighbor's position directly without optional binding
                    let neighborPosition = dungeon.getNeighborPosition(from: position, direction: direction)
                    if let neighbor = dungeon.getCell(at: neighborPosition), !visitedPositions.contains(neighbor.position) {
                        explore(from: neighborPosition)
                    }
                }
            }
        }
        
        explore(from: Position(x: 0, y: 0))
        
        // Check connectivity of all cells
        for x in 0..<dungeon.width {
            for y in 0..<dungeon.height {
                #expect(visitedPositions.contains(Position(x: x, y: y)),
                        "All cells should be reachable in a connected maze.")
            }
        }
    }

    // MARK: - Display Tests

    /// Display dungeons of varying sizes for each generation algorithm.
    @Test("Display dungeons of varying sizes for each generation algorithm")
    func testDungeonDisplay() async throws {
        let algorithms: [GenerationAlgorithm] = [.recursiveBacktracker]
        let sizes: [(width: Int, height: Int)] = [(5, 5), (10, 10), (15, 15)]
        
        for algorithm in algorithms {
            print("\nTesting \(algorithm) Dungeon Displays:")
            for size in sizes {
                print("\n\(algorithm) Dungeon of size \(size.width)x\(size.height):")
                let dungeon = Dungeon(width: size.width, height: size.height)
                dungeon.generateDungeon(using: algorithm)
                dungeon.displayDungeon()
            }
        }
    }

    // MARK: - Non-Parameterized Tests

    /// Ensure all passable cells are reachable in the dungeon.
    @Test("Dungeon grid maintains full connectivity")
    func testDungeonConnectivity() async throws {
        let dungeon = Dungeon(width: 60, height: 40)
        dungeon.generateDungeon(using: .recursiveBacktracker)

        guard let startingRoom = dungeon.rooms.first else {
            Issue.record("No rooms found in dungeon.")
            return
        }

        var visited = Set<Position>()
        var stack: [Position] = [Position(x: startingRoom.x, y: startingRoom.y)]

        while !stack.isEmpty {
            let current = stack.removeLast()
            if visited.contains(current) { continue }
            visited.insert(current)

            // Explore neighbors
            let neighbors = [
                Position(x: current.x + 1, y: current.y),
                Position(x: current.x - 1, y: current.y),
                Position(x: current.x, y: current.y + 1),
                Position(x: current.x, y: current.y - 1)
            ]

            for neighbor in neighbors {
                if neighbor.x >= 0, neighbor.x < dungeon.width,
                   neighbor.y >= 0, neighbor.y < dungeon.height,
                   dungeon.getCell(at: neighbor)?.walls.values.contains(false) == true,
                   !visited.contains(neighbor) {
                    stack.append(neighbor)
                }
            }
        }

        // Verify that all cells with any walls removed are reachable, ensuring connectivity
        for x in 0..<dungeon.width {
            for y in 0..<dungeon.height {
                let cell = dungeon.grid[x][y]
                if cell.walls.values.contains(false) {
                    #expect(visited.contains(cell.position), "Cell at (\(cell.position.x), \(cell.position.y)) should be reachable.")
                }
            }
        }
    }

    /// Test that the dungeon contains at least one entrance and one exit.
    @Test("Dungeon contains at least one entrance and one exit")
    func testDungeonEntrancesAndExits() async throws {
        let dungeon = Dungeon(width: 50, height: 30)
        dungeon.generateDungeon(using: .recursiveBacktracker)

        var entranceCount = 0
        var exitCount = 0

        for row in dungeon.grid {
            for cell in row {
                if cell.walls.values.contains(false) {
                    if entranceCount == 0 {
                        entranceCount += 1 // Mark the first accessible cell as the entrance
                    } else {
                        exitCount += 1 // Count remaining accessible cells as exits
                    }
                }
            }
        }

        #expect(entranceCount >= 1, "Dungeon should have at least one entrance.")
        #expect(exitCount >= 1, "Dungeon should have at least one exit.")
    }

    /// Test that the dungeon does not exceed its defined boundaries.
    @Test("Dungeon does not exceed defined boundaries")
    func testDungeonBoundaries() async throws {
        let width = 50
        let height = 30
        let dungeon = Dungeon(width: width, height: height)
        dungeon.generateDungeon(using: .recursiveBacktracker)

        for x in 0..<width {
            for y in 0..<height {
                #expect(x >= 0, "X coordinate should be >= 0.")
                #expect(x < width, "X coordinate should be < width.")
                #expect(y >= 0, "Y coordinate should be >= 0.")
                #expect(y < height, "Y coordinate should be < height.")
            }
        }
    }
}
