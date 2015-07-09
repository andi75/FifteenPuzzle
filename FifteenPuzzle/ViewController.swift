//
//  ViewController.swift
//  FifteenPuzzle
//
//  Created by Andreas Umbach on 12/05/15.
//  Copyright (c) 2015 Andreas Umbach. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tileView: UIView!
    var board = PuzzleBoard(rows: 4, columns: 4)
    
    let padding = 10.0
    
    var buttons = [PuzzleTileButton]()
    
    func tileRect(position: TilePosition) -> CGRect
    {
        let totalColumnPadding = Double(board.columns + 1) * padding
        let totalRowPadding = Double(board.rows + 1) * padding
        
        let sx = ( Double(tileView.bounds.width) - totalColumnPadding ) / Double(board.rows)
        let sy = ( Double(tileView.bounds.height) - totalRowPadding) / (Double)(board.columns)
        
        
        let x = (Double)(position.column) * padding + (Double)(position.column - 1) * sx
        let y = (Double)(position.row) * padding + (Double)(position.row - 1) * sy
        
        return CGRectMake( CGFloat(x), CGFloat(y), CGFloat(sx), CGFloat(sy))
    }
    
    func updateButtons()
    {
        for button in buttons
        {
            button.frame = tileRect(button.tile.position)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tileView.backgroundColor = UIColor.blueColor()
        
        for tile in board.tiles
        {
            let col = tile.position.column
            let row = tile.position.row
            var view = PuzzleTileButton(tile: tile, frame:tileRect(tile.position))
            buttons.append(view)
            
            view.backgroundColor = UIColor(hue: CGFloat(random()) / CGFloat(RAND_MAX), saturation: 1, brightness: 1, alpha: 1)
            
            view.addTarget(self, action: "tileIsPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            tileView.addSubview(view)
        }
    }
    
    func buttonAt(position: TilePosition) -> PuzzleTileButton?
    {
        for button in buttons
        {
            if(button.tile.position.row == position.row && button.tile.position.column == position.column)
            {
                return button
            }
        }
        return nil
    }
    
    func tileIsPressed(sender: PuzzleTileButton)
    {
        let tile = sender.tile
        
        //        println("touched: \(tile.index)")
        moveTile(tile, speed: 0.5, delay: 0.0)
    }
    
    func moveTile(tile: PuzzleTile, speed: Double, delay: Double)
    {
        let movements = board.tileMovementsFor(tile.position)
        for  movement in movements
        {
            let button = buttonAt(movement.start)!
            UIView.animateWithDuration(speed, delay: delay, options: UIViewAnimationOptions.allZeros, animations: { button.frame = self.tileRect(movement.end); }, completion: nil)
            board.move(movement)
        }
//         updateButtons()
    }
    
    @IBAction func shuffle()
    {
        // Generate a hundred moves, making the animation between moves faster and faster
        // restrictions: always alternate row/column moves
        
        let speedlist = [ 0.3, 0.2, 0.1, 0.05, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01]
        var delay = 0.0
        for i in 0..<100
        {
            let speed = speedlist[i / 10]
            if(i % 2 == 0)
            {
                var row = random() % board.rows + 1
                if(row != board.emptySquare.row)
                {
                    self.moveTile(board.tileAt(TilePosition(row: row, column: board.emptySquare.column))!, speed: speed, delay: delay)
                }
            }
            else
            {
                var col = random() % board.columns + 1
                if(col != board.emptySquare.column)
                {
                    self.moveTile(board.tileAt(TilePosition(row: board.emptySquare.row, column: col))!, speed: speed, delay: delay)
                }
            }
            delay += speed
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

