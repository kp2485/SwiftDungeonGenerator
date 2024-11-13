//
//  Dungeon.swift
//  DungeonGenerator
//
//  Created by Kyle Peterson on 11/11/24.
//


class Dungeon {
    var width: Int
    var height: Int
    var grid: [[Tile]]
    var rooms: [Room] = []

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.grid = Array(repeating: Array(repeating: WallTile(x: 0, y: 0), count: height), count: width)
        initializeGrid()
    }

    private func initializeGrid() {
        for x in 0..<width {
            for y in 0..<height {
                grid[x][y] = WallTile(x: x, y: y)
            }
        }
    }

    func generateDungeon() {
        // Example: Generate a single room for simplicity
        let roomWidth = Int(Double(width) * 0.6)
        let roomHeight = Int(Double(height) * 0.6)
        let startX = (width - roomWidth) / 2
        let startY = (height - roomHeight) / 2

        var roomTiles: [Tile] = []

        for x in startX..<(startX + roomWidth) {
            for y in startY..<(startY + roomHeight) {
                let floorTile = FloorTile(x: x, y: y)
                grid[x][y] = floorTile
                roomTiles.append(floorTile)
            }
        }

        let room = Room(tiles: roomTiles)
        rooms.append(room)

        // Place doors
        placeDoors(in: room)
        // Place traps
        placeTraps(in: room)
        // Place loot
        placeLoot(in: room)
        // Place entities
        placeEntities(in: room)
    }

    private func placeDoors(in room: Room) {
        // For simplicity, place a door at the center of each wall
        let doorPositions = [
            (x: room.tiles.first!.x, y: (room.tiles.first!.y + room.tiles.last!.y) / 2), // Left wall
            (x: room.tiles.last!.x, y: (room.tiles.first!.y + room.tiles.last!.y) / 2),  // Right wall
            (x: (room.tiles.first!.x + room.tiles.last!.x) / 2, y: room.tiles.first!.y), // Top wall
            (x: (room.tiles.first!.x + room.tiles.last!.x) / 2, y: room.tiles.last!.y)   // Bottom wall
        ]

        for pos in doorPositions {
            let doorTile = DoorTile(x: pos.x, y: pos.y, isLocked: Bool.random())
            grid[pos.x][pos.y] = doorTile
        }
    }

    private func placeTraps(in room: Room) {
        // Randomly place a few traps
        for _ in 0..<3 {
            if let tile = room.tiles.randomElement() {
                let trapTile = TrapTile(x: tile.x, y: tile.y, trapType: "Spike Trap")
                grid[tile.x][tile.y] = trapTile
            }
        }
    }

    private func placeLoot(in room: Room) {
        // Place a chest with loot
        if let tile = room.tiles.randomElement() {
            let loot = Loot(name: "Gold Coins", value: Int.random(in: 10...100))
            room.addItem(loot)
            grid[tile.x][tile.y].symbol = "C" // 'C' for Chest
        }
    }

    private func placeEntities(in room: Room) {
        // Place an enemy
        if let tile = room.tiles.randomElement() {
            let enemy = Enemy(enemyType: "Goblin", x: tile.x, y: tile.y)
            room.addEntity(enemy)
            grid[tile.x][tile.y].symbol = enemy.symbol
        }

        // Place an NPC
        if let tile = room.tiles.randomElement() {
            let npc = NPC(name: "Old Wizard", x: tile.x, y: tile.y, dialogue: "Beware of the traps ahead!")
            room.addEntity(npc)
            grid[tile.x][tile.y].symbol = npc.symbol
        }
    }

    func displayDungeon() {
        for y in 0..<height {
            var row = ""
            for x in 0..<width {
                row += String(grid[x][y].symbol)
            }
            print(row)
        }
    }
}
