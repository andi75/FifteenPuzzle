//
//  PuzzleBoard.swift
//  FifteenPuzzle
//
//  Created by Andreas Umbach on 15/05/15.
//  Copyright (c) 2015 Andreas Umbach. All rights reserved.
//

import Foundation

class PuzzleBoard {
    
    var rows: Int, columns: Int
    
    var emptySquare: TilePosition
    
    var tiles = [PuzzleTile]()
    
    init(rows: Int, columns: Int)
    {
        self.rows = rows
        self.columns = columns
        
        self.emptySquare = TilePosition(row: rows, column: columns)
        
        for i in 0..<(rows * columns - 1)
        {
            let pos = TilePosition(row: i / columns + 1, column: (i % columns) + 1)
            let tile = PuzzleTile( position: pos, index: i + 1)
            tiles.append(tile)
        }
    }
    
    func isInRowToEmptySquare(position: TilePosition) -> Bool
    {
        return position.row == emptySquare.row || position.column == emptySquare.column
    }
    
    func isNextToEmptySquare(position: TilePosition) -> Bool
    {
        return
            (position.row == emptySquare.row && abs(position.column - emptySquare.column) == 1) ||
            (position.column == emptySquare.column && abs(position.row - emptySquare.row) == 1)
    }
    
    func tileAt(position: TilePosition) -> PuzzleTile?
    {
        for tile in self.tiles
        {
            if tile.position.row == position.row && tile.position.column == position.column
            {
                return tile
            }
        }
        return nil
    }
    
    func move(movement: TileMovement)
    {
        let tile = self.tileAt(movement.start)

        assert(movement.end == emptySquare, "destination not empty")
        assert(tile != nil, "tile not found")
        
        emptySquare = movement.start
        tile?.position = movement.end
    }
    
    func tileMovementsFor(position: TilePosition) -> [TileMovement]
    {
        var movements: [TileMovement] = []
        
        if(self.isNextToEmptySquare(position))
        {
            movements.append(TileMovement(start: position, end: emptySquare))
        }
        else if(self.isInRowToEmptySquare(position))
        {
            var dr = 0, dc = 0
            if(self.emptySquare.row != position.row)
            {
                dr = (self.emptySquare.row - position.row) / abs(self.emptySquare.row - position.row)
            }
            if(self.emptySquare.column != position.column) {
                dc = (self.emptySquare.column - position.column) / abs(self.emptySquare.column - position.column)
            }
            
            var row = self.emptySquare.row
            var col = self.emptySquare.column
            let endrow = position.row
            let endcol = position.column
            do
            {
                let esq = TilePosition(row: row, column: col)
                
                row -= dr
                col -= dc
                let tmptile = self.tileAt( TilePosition(row: row , column: col) )
        
                assert(tmptile != nil, "tile not found")
//                println("moving tile at \(row), \(col)")
                movements.append(TileMovement(start: tmptile!.position, end: esq))
            } while row != endrow || col != endcol
        }
        
        return movements
    }
}