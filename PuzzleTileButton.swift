//
//  PuzzleTileButton.swift
//  FifteenPuzzle
//
//  Created by Andreas Umbach on 15/05/15.
//  Copyright (c) 2015 Andreas Umbach. All rights reserved.
//

import UIKit

class PuzzleTileButton : UIButton
{
    var tile : PuzzleTile
    
    var positionOnScreen: TilePosition
    
    required init(tile: PuzzleTile, frame: CGRect)
    {
        self.tile = tile
        self.positionOnScreen = tile.position
        super.init(frame: frame)
        self.setTitle("\(tile.index)", forState: UIControlState.Normal)
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
