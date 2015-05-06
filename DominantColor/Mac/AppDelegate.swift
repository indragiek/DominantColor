//
//  AppDelegate.swift
//  DominantColor
//
//  Created by Indragie on 12/18/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import Cocoa
import DominantColor

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
    
    var image: NSImage?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        imageView.delegate = self
    }
    
    // MARK: DragAndDropImageViewDelegate
    
    @IBAction func runBenchmark(sender: NSButton) {
        if let image = image {
            let nValues: [Int] = [100, 1000, 2000, 5000, 10000]
            let CGImage = image.CGImageForProposedRect(nil, context: nil, hints: nil)!.takeUnretainedValue()
            for n in nValues {
                let ns = dispatch_benchmark(5) {
                    dominantColorsInImage(CGImage, maxSampledPixels: n)
                    return
                }
                println("n = \(n) averaged \(ns/1000000) ms")
            }
        }
    }
    
    func dragAndDropImageView(imageView: DragAndDropImageView, droppedImage image: NSImage?) {
        if let image = image {
            imageView.image = image
            
            self.image = image
            let colors = image.dominantColors()
            let boxes = [box1, box2, box3, box4, box5, box6]
            
            for box in boxes {
                box.fillColor = NSColor.clearColor()
            }
            for i in 0..<min(colors.count, boxes.count) {
                boxes[i].fillColor = colors[i]
            }
        }
    }
}

