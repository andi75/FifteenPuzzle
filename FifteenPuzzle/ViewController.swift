//
//  ViewController.swift
//  FifteenPuzzle
//
//  Created by Andreas Umbach on 12/05/15.
//  Copyright (c) 2015 Andreas Umbach. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tileView: UIView!
    var board = PuzzleBoard(rows: 4, columns: 4)
    
    var buttons = [PuzzleTileButton]()
    var showNumbers = true
    
    var tileImageViews = [UIImageView]()
    
    var imagePicker = UIImagePickerController()
    // var image = UIImage(named: "kitty_square.jpg")!
    var image = UIImage(named: "Martinsloch.jpg")!

    func padding() -> Double
    {
        return round(Double(tileView.bounds.width) * 0.006)
    }
    
    func tileBounds() -> (Double, Double)
    {
        let totalColumnPadding = Double(board.columns + 1) * padding()
        let totalRowPadding = Double(board.rows + 1) * padding()
        
        let sx = ( Double(tileView.bounds.width) - totalColumnPadding ) / Double(board.rows)
        let sy = ( Double(tileView.bounds.height) - totalRowPadding) / (Double)(board.columns)
       
        return (sx, sy)
    }
    
    func tileRect(position: TilePosition) -> CGRect
    {
        let (sx, sy) = tileBounds()
        
        let x = (Double)(position.column) * padding() + (Double)(position.column - 1) * sx
        let y = (Double)(position.row) * padding() + (Double)(position.row - 1) * sy
        
        return CGRectMake( CGFloat(x), CGFloat(y), CGFloat(sx), CGFloat(sy))
    }
    
    func redoTiles()
    {
        println("Block Executed On \(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))");
        println("Main queue is \(dispatch_queue_get_label(dispatch_get_main_queue()))");
        
        self.createTileImages()
        self.createButtons()
        
        println("done with redoing tiles")
    }
    
    func orientationChanged(notification: NSNotification)
    {
        // updateButtons()
        redoTiles()
        // so, it looks like this is happening on the main thread
//        println("Block Executed On \(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))");
//        println("Main queue is \(dispatch_queue_get_label(dispatch_get_main_queue()))");
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /* Listen for the notification */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:",
        name: UIDeviceOrientationDidChangeNotification, object: nil)
        redoTiles()
    }
    
    override func viewDidDisappear(animated: Bool) { super.viewDidDisappear(animated)
        /* Stop listening for the notification */ NSNotificationCenter.defaultCenter().removeObserver(self,
        name: UIDeviceOrientationDidChangeNotification,
        object: nil)
    }
    
    
    func updateButtons()
    {
        for button in buttons
        {
            button.frame = tileRect(button.tile.position)
            if(showNumbers)
            {
                button.setTitle("\(button.tile.index)", forState: UIControlState.Normal)
            }
            else
            {
                button.setTitle("", forState: UIControlState.Normal)
            }
        }
//        let (sx, sy) = tileBounds()
//        for tiv in tileImageViews
//        {
//            tiv.bounds = CGRectMake(0.0, 0.0, CGFloat(sx), CGFloat(sy))
//            let oldframe = tiv.frame
//            tiv.frame = CGRectMake(oldframe.origin.x, oldframe.origin.y, CGFloat(sx), CGFloat(sy))
//        }
    }
    
    func createTileImages()
    {
        var scale: CGFloat = 1.0
        // choose aspect
        if(image.size.width < image.size.height)
        {
            scale = tileView.bounds.width / image.size.width
        }
        else
        {
            scale = tileView.bounds.height / image.size.height
        }
        println("would be scaling image down with a factor of \(scale)")
        
//        let scaledImage = UIImage(CGImage: image.CGImage!, scale: 1 / scale, orientation: UIImageOrientation.Up)!
//        let scaledImage = UIImage(CGImage: image.CGImage!, scale: 1, orientation: UIImageOrientation.Up)!

        let matScale = CGAffineTransformMakeScale(scale, scale)
        
        let ciimage = CIImage(CGImage: image.CGImage!)
        assert(ciimage != nil)
        
        let result: CIImage = ciimage!.imageByApplyingTransform(matScale)!
    
        let context = CIContext(options:nil)
        let cgImage = context.createCGImage(result, fromRect: result.extent())
        
        let scaledImage = UIImage(CGImage: cgImage)!
        
        tileImageViews = [UIImageView]()
        
        // note: tile index starts at 1
        
        let size = min(scaledImage.size.width, scaledImage.size.height)
        let x_offset = (scaledImage.size.width - size) / 2
        let y_offset = (scaledImage.size.height - size) / 2
        
        let tiles = 4
        
        let tilewidth = size / CGFloat(tiles)
        let tileheight = size / CGFloat(tiles)
        
        var y = y_offset
        
        for var ty = 0; ty < tiles; ty++
        {
            var x = x_offset
            for var tx = 0; tx < tiles; tx++
            {
                autoreleasepool {
                    let dx : CGFloat = 2.0, dy : CGFloat = 2.0
                    
                    let rect = CGRectInset(CGRectMake(x, y, tilewidth, tileheight), dx, dy)
                    let img = CGImageCreateWithImageInRect(scaledImage.CGImage, rect)
                    let tileView = UIImageView(image: UIImage(CGImage:img))
                    tileView.layer.cornerRadius = tilewidth / 8.0
                    //                tileView.clipsToBounds = true
                    self.tileImageViews.append(tileView)
                    
                    x += tilewidth
                }
            }
            y += tileheight
        }
    }
    
    func createButtons()
    {
        // remove old buttons from view
        for button in buttons
        {
            button.removeFromSuperview()
        }
        buttons = []
        // hopefully all buttons will be cleaned up by the ARC now. TODO: check if that's the case!
        
        for tile in board.tiles
        {
            autoreleasepool {
                var ptb = PuzzleTileButton(tile: tile, frame:tileRect(tile.position))
                buttons.append(ptb)
                
                // ptb.backgroundColor = UIColor(hue: CGFloat(random()) / CGFloat(RAND_MAX), saturation: 1, brightness: 1, alpha: 1)
                
                ptb.addTarget(self, action: "tileIsPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                let tiv = tileImageViews[tile.index - 1]
                tiv.frame = CGRectMake(0, 0, ptb.bounds.width, ptb.bounds.height)
                tiv.bounds = CGRectMake(0, 0, ptb.bounds.width, ptb.bounds.height)
                tiv.contentMode = UIViewContentMode.ScaleAspectFit
                ptb.addSubview(tiv)
                tileView.addSubview(ptb)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

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
    
    @IBAction func showHideNumbers(sender: UIButton) {
        showNumbers = !showNumbers
        if(showNumbers)
        {
            sender.setTitle("Hide Numbers", forState: UIControlState.Normal)
        }
        else
        {
            sender.setTitle("Show Numbers", forState: UIControlState.Normal)
        }
        sender.sizeToFit()
        updateButtons()
    }
    @IBAction func resetTiles(sender: UIButton) {
        board.resetBoard()
        updateButtons()
    }
    
    @IBAction func changeImage(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
//            println("picking image")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
//            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
     
    }

    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = pickedImage
            // no need to redo Tiles since that will be done in viewDidAppear after the view Controller is gone
            // redoTiles()
        }
        dismissViewControllerAnimated(true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

