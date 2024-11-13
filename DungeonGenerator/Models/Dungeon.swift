//
//  Dungeon.swift
//  DungeonGenerator
//
//  Created by Kyle Peterson on 11/11/24.
//

class Dungeon {
    let width: Int
    let height: Int
    var grid: [[Cell]]
    var rooms: [Position] = [] // Positions representing rooms; can be expanded to Room structures
    
    /// Initializes a new dungeon with specified width and height.
    /// - Parameters:
    ///   - width: The width of the dungeon grid.
    ///   - height: The height of the dungeon grid.
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.grid = []
        
        // Initialize the grid with cells
        for x in 0..<width {
            var row: [Cell] = []
            for y in 0..<height {
                row.append(Cell(x: x, y: y))
            }
            self.grid.append(row)
        }
    }
    
    /// Generates the dungeon based on the specified generation algorithm.
    /// - Parameter algorithm: The maze generation algorithm to use.
    func generateDungeon(using algorithm: GenerationAlgorithm) {
        switch algorithm {
        case .recursiveBacktracker:
            generateMazeRecursiveBacktracker()
        }
    }
    
    /// Retrieves a cell at a given position.
    /// - Parameter position: The position of the desired cell.
    /// - Returns: The cell at the specified position, or nil if out of bounds.
    func getCell(at position: Position) -> Cell? {
        guard position.x >= 0, position.x < width,
              position.y >= 0, position.y < height else {
            return nil
        }
        return grid[position.x][position.y]
    }
    
    /// Updates a cell at a given position.
    /// - Parameter cell: The cell to update.
    func setCell(_ cell: Cell) {
        let x = cell.position.x
        let y = cell.position.y
        guard x >= 0, x < width, y >= 0, y < height else { return }
        grid[x][y] = cell
    }
    
    /// Displays the dungeon grid in the console.
    func displayDungeon() {
        for y in 0..<height {
            var topLine = ""
            var middleLine = ""
            for x in 0..<width {
                let cell = grid[x][y]
                
                // Top wall
                topLine += cell.walls[.north]! ? "───" : "   "
                topLine += " "
                
                // Side walls
                middleLine += cell.walls[.west]! ? "|" : " "
                middleLine += "   "
            }
            // Last cell's east wall
            middleLine += "|"
            print(topLine)
            print(middleLine)
        }
        
        // Bottom walls
        var bottomLine = ""
        for x in 0..<width {
            let cell = grid[x][height - 1]
            bottomLine += cell.walls[.south]! ? "───" : "   "
            bottomLine += " "
        }
        print(bottomLine)
    }
}

extension Dungeon {
    
    /// Generates a maze using the Recursive Backtracker (Depth-First Search) algorithm.
    func generateMazeRecursiveBacktracker() {
        // Start at a random cell
        let startX = Int.random(in: 0..<width)
        let startY = Int.random(in: 0..<height)
        var stack: [Position] = []
        
        // Mark the starting cell as visited and push it to the stack
        var currentCell = grid[startX][startY]
        currentCell.visited = true
        setCell(currentCell)
        stack.append(currentCell.position)
        
        // Loop until the stack is empty
        while !stack.isEmpty {
            let currentPosition = stack.last!
            guard var current = getCell(at: currentPosition) else {
                stack.removeLast()
                continue
            }
            
            // Get all unvisited neighbors
            let neighbors = getUnvisitedNeighbors(of: current)
            
            if !neighbors.isEmpty {
                // Choose a random unvisited neighbor
                let randomIndex = Int.random(in: 0..<neighbors.count)
                let chosenDirection = neighbors[randomIndex].direction
                let neighborPosition = neighbors[randomIndex].position
                
                // Remove the wall between current cell and chosen neighbor
                removeWall(between: &current, in: chosenDirection)
                setCell(current)
                
                if var neighbor = getCell(at: neighborPosition) {
                    removeWall(between: &neighbor, in: neighbors[randomIndex].direction.opposite)
                    neighbor.visited = true
                    setCell(neighbor)
                    stack.append(neighbor.position)
                }
            } else {
                // Backtrack if no unvisited neighbors
                stack.removeLast()
            }
        }
    }
    
    /// Represents a neighbor cell with its direction relative to the current cell.
    struct Neighbor {
        let position: Position
        let direction: Direction
    }
    
    /// Retrieves all unvisited neighbors of a given cell.
    /// - Parameter cell: The current cell.
    /// - Returns: An array of unvisited neighbors with their respective directions.
    private func getUnvisitedNeighbors(of cell: Cell) -> [Neighbor] {
        var neighbors: [Neighbor] = []
        let directions: [Direction] = Direction.allCases.shuffled() // Shuffle to ensure randomness
        
        for direction in directions {
            let neighborPos = getNeighborPosition(from: cell.position, direction: direction)
            if let neighbor = getCell(at: neighborPos), !neighbor.visited {
                neighbors.append(Neighbor(position: neighborPos, direction: direction))
            }
        }
        
        return neighbors
    }
    
    /// Calculates the position of a neighbor cell based on a direction.
    /// - Parameters:
    ///   - position: The current cell's position.
    ///   - direction: The direction to the neighbor.
    /// - Returns: The neighbor's position.
    func getNeighborPosition(from position: Position, direction: Direction) -> Position {
        switch direction {
        case .north:
            return Position(x: position.x, y: position.y - 1)
        case .south:
            return Position(x: position.x, y: position.y + 1)
        case .east:
            return Position(x: position.x + 1, y: position.y)
        case .west:
            return Position(x: position.x - 1, y: position.y)
        }
    }
    
    /// Removes the wall in a specified direction from a cell.
    /// - Parameters:
    ///   - cell: The current cell to modify.
    ///   - direction: The direction of the wall to remove.
    private func removeWall(between cell: inout Cell, in direction: Direction) {
        cell.walls[direction] = false
    }
}
