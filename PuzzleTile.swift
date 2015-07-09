//
//  PuzzleTile.swift
//  FifteenPuzzle
//
//  Created by Andreas Umbach on 15/05/15.
//  Copyright (c) 2015 Andreas Umbach. All rights reserved.
//

import Foundation

struct TilePosition : Equatable
{
    var row: Int, column: Int
}

func == (left: TilePosition, right: TilePosition) -> Bool
{
    return (left.row == right.row) && (left.column == right.column)
}


struct TileMovement
{
    var start: TilePosition, end: TilePosition
}

class PuzzleTile
{
    var index: Int
    var position: TilePosition
    
    init(position: TilePosition, index: Int)
    {
        self.index = index
        self.position = position
    }
}