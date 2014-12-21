//
//  AppDelegate.swift
//  DominantColor
//
//  Created by Indragie on 12/18/14.
//  Copyright (c) 2014 indragie. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, DragAndDropImageViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var box1: NSBox!
    @IBOutlet weak var box2: NSBox!
    @IBOutlet weak var box3: NSBox!
    @IBOutlet weak var box4: NSBox!
    @IBOutlet weak var box5: NSBox!
    @IBOutlet weak var box6: NSBox!
    @IBOutlet weak var imageView: DragAndDropImageView!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        imageView.delegate = self
    }
    
    // MARK: DragAndDropImageViewDelegate
    
    func dragAndDropImageView(imageView: DragAndDropImageView, droppedImage image: NSImage?) {
        if let image = image {
            imageView.image = image
            
            let cgImage = image.CGImageForProposedRect(nil, context: nil, hints: nil)!.takeUnretainedValue()
            
            let nValues: [UInt] = [10, 100, 1000, 2000, 5000, 10000]
            for n in nValues {
                let ns = dispatch_benchmark(5) {
                    dominantColorsInImage(cgImage, n, 98251)
                    return
                }
                println("n = \(n) averaged \(ns/1000000) ms")
            }
            
            let colors = dominantColorsInImage(cgImage, 1000, 98251)
            let boxes = [box1, box2, box3, box4, box5, box6]
            
            for box in boxes {
                box.fillColor = NSColor.clearColor()
            }
            for i in 0..<min(countElements(colors), countElements(boxes)) {
                boxes[i].fillColor = NSColor(CGColor: colors[i])
            }
        }
    }
}

