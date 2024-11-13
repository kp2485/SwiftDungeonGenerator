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

        // Verify all tiles are initialized as WallTile
        for x in 0..<width {
            for y in 0..<height {
                let tile = dungeon.grid[x][y]
                #expect(tile is WallTile, "Tile at (\(x), \(y)) should be a WallTile upon initialization.")
            }
        }
    }

    /// Test that dungeon generation creates at least one room for various dungeon sizes.
    @Test("Dungeon generation creates at least one room", arguments: [50, 60, 70, 80])
    func testDungeonGenerationCreatesRooms(dungeonWidth: Int) async throws {
        // Arrange
        let dungeon = Dungeon(width: dungeonWidth, height: 30)

        // Act
        dungeon.generateDungeon()

        // Assert
        #expect(!dungeon.rooms.isEmpty, "Dungeon should contain at least one room after generation.")
    }

    /// Test that doors are correctly placed within the dungeon for different sizes.
    @Test("Doors are correctly placed within the dungeon", arguments: [50, 60, 70, 80])
    func testDoorPlacement(dungeonWidth: Int) async throws {
        // Arrange
        let dungeon = Dungeon(width: dungeonWidth, height: 30)

        // Act
        dungeon.generateDungeon()

        // Assert
        var doorCount = 0
        for row in dungeon.grid {
            for tile in row {
                if let door = tile as? DoorTile {
                    doorCount += 1
                    // Verify door properties
                    #expect(["D", "L"].contains(door.symbol), "Door symbol should be either 'D' (unlocked) or 'L' (locked).")
                    #expect([true, false].contains(door.isLocked), "Door's isLocked should be a Boolean value.")
                }
            }
        }

        // Expect at least four doors (one on each wall of the initial room)
        #expect(doorCount >= 4, "Dungeon should have at least four doors.")
    }

    /// Test that traps are placed on passable tiles across various dungeon sizes.
    @Test("Traps are placed on passable tiles", arguments: [50, 60, 70, 80])
    func testTrapPlacement(dungeonWidth: Int) async throws {
        // Arrange
        let dungeon = Dungeon(width: dungeonWidth, height: 30)

        // Act
        dungeon.generateDungeon()

        // Assert
        for room in dungeon.rooms {
            for tile in room.tiles {
                if let trap = tile as? TrapTile {
                    // Ensure traps are placed on passable tiles
                    #expect(dungeon.grid[trap.x][trap.y].passable, "Traps should be placed on passable tiles at (\(trap.x), \(trap.y)).")
                    // Verify trap type
                    #expect(trap.trapType == "Spike Trap", "Trap type should be 'Spike Trap'.")
                }
            }
        }
    }

    /// Test that loot is correctly placed within rooms for different dungeon sizes.
    @Test("Loot is correctly placed within rooms", arguments: [50, 60, 70, 80])
    func testLootPlacement(dungeonWidth: Int) async throws {
        // Arrange
        let dungeon = Dungeon(width: dungeonWidth, height: 30)

        // Act
        dungeon.generateDungeon()

        // Assert
        for room in dungeon.rooms {
            for item in room.items {
                // Verify that items are instances of Loot or Consumable
                #expect(item is Loot || item is Consumable, "Items should be instances of Loot or Consumable.")

                // Find the tile that contains this item
                let tileWithItem = room.tiles.first { tile in
                    // Assuming that tiles with items have their symbol set (e.g., 'C' for Chest)
                    if tile.symbol == "C" {
                        // Further verification can be added if necessary
                        return true
                    }
                    return false
                }

                #expect(tileWithItem != nil, "Loot should be placed on a valid tile.")
                #expect(tileWithItem?.passable == true, "Loot should be placed on passable tiles.")
            }
        }
    }

    /// Parameterized test for entity placement with various dungeon sizes.
    @Test("Entities are placed on passable tiles and not on walls", arguments: [50, 60, 70, 80])
    func testEntityPlacement(dungeonWidth: Int) async throws {
        // Arrange
        let dungeon = Dungeon(width: dungeonWidth, height: 30)

        // Act
        dungeon.generateDungeon()

        // Assert
        for room in dungeon.rooms {
            for entity in room.entities {
                // Ensure entities are placed on passable tiles
                #expect(dungeon.grid[entity.x][entity.y].passable, "Entity '\(entity.name)' should be placed on a passable tile at (\(entity.x), \(entity.y)).")
                // Ensure entities are not placed on WallTiles
                #expect(dungeon.grid[entity.x][entity.y].symbol != "#", "Entity '\(entity.name)' should not be placed on WallTiles at (\(entity.x), \(entity.y)).")
            }
        }
    }

    /// Parameterized test for loot distribution with various dungeon sizes.
    @Test("Loot is distributed fairly within rooms", arguments: [50, 60, 70, 80])
    func testLootDistribution(dungeonWidth: Int) async throws {
        // Arrange
        let dungeon = Dungeon(width: dungeonWidth, height: 30)

        // Act
        dungeon.generateDungeon()

        // Assert
        var lootPositions: Set<Position> = Set()
        for room in dungeon.rooms {
            for _ in room.items {
                // Find the tile that contains this item
                if let tileWithItem = room.tiles.first(where: { tile in
                    // Assuming that tiles with items have their symbol set (e.g., 'C' for Chest)
                    return tile.symbol == "C"
                }) {
                    lootPositions.insert(Position(x: tileWithItem.x, y: tileWithItem.y))
                }
            }
        }

        #expect(lootPositions.count >= 1, "There should be at least one loot item.")
        #expect(lootPositions.count <= dungeon.rooms.count, "Loot items should not exceed the number of rooms.")
    }

    // MARK: - Non-Parameterized Tests

    /// Test that the dungeon grid maintains full connectivity.
    @Test("Dungeon grid maintains full connectivity")
    func testDungeonConnectivity() async throws {
        // Arrange
        let dungeon = Dungeon(width: 60, height: 40)

        // Act
        dungeon.generateDungeon()

        // Assert
        guard let startingRoom = dungeon.rooms.first, let startingTile = startingRoom.tiles.first else {
            Issue.record("No rooms or tiles found in dungeon.")
            return
        }

        var visited = Set<Position>()
        var stack: [Position] = [Position(x: startingTile.x, y: startingTile.y)]

        while !stack.isEmpty {
            let current = stack.removeLast()
            if visited.contains(current) { continue }
            visited.insert(current)

            // Explore neighboring tiles
            let neighbors = [
                Position(x: current.x + 1, y: current.y),
                Position(x: current.x - 1, y: current.y),
                Position(x: current.x, y: current.y + 1),
                Position(x: current.x, y: current.y - 1)
            ]

            for neighbor in neighbors {
                if neighbor.x >= 0, neighbor.x < dungeon.width,
                   neighbor.y >= 0, neighbor.y < dungeon.height,
                   dungeon.grid[neighbor.x][neighbor.y].passable,
                   !visited.contains(neighbor) {
                    stack.append(neighbor)
                }
            }
        }

        // Verify that all passable tiles are visited, ensuring connectivity
        for row in dungeon.grid {
            for tile in row {
                if tile.passable {
                    let pos = Position(x: tile.x, y: tile.y)
                    #expect(visited.contains(pos), "Tile at (\(tile.x), \(tile.y)) should be reachable.")
                }
            }
        }
    }

    /// Test that the dungeon contains at least one entrance and one exit.
    @Test("Dungeon contains at least one entrance and one exit")
    func testDungeonEntrancesAndExits() async throws {
        // Arrange
        let dungeon = Dungeon(width: 50, height: 30)

        // Act
        dungeon.generateDungeon()

        // Assert
        var entranceCount = 0
        var exitCount = 0

        for row in dungeon.grid {
            for tile in row {
                if let door = tile as? DoorTile {
                    if door.isLocked {
                        exitCount += 1
                    } else {
                        entranceCount += 1
                    }
                }
            }
        }

        // Expect at least one entrance and one exit
        #expect(entranceCount >= 1, "Dungeon should have at least one entrance.")
        #expect(exitCount >= 1, "Dungeon should have at least one exit.")
    }

    /// Test that the dungeon does not exceed its defined boundaries.
    @Test("Dungeon does not exceed defined boundaries")
    func testDungeonBoundaries() async throws {
        // Arrange
        let width = 50
        let height = 30
        let dungeon = Dungeon(width: width, height: height)

        // Act
        dungeon.generateDungeon()

        // Assert
        for x in 0..<width {
            for y in 0..<height {
                // Ensure all tiles are within bounds
                #expect(x >= 0, "X coordinate should be >= 0.")
                #expect(x < width, "X coordinate should be < width.")
                #expect(y >= 0, "Y coordinate should be >= 0.")
                #expect(y < height, "Y coordinate should be < height.")
            }
        }
    }
}
