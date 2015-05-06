//
//  ViewController.swift
//  Dominant Color iOS
//
//  Created by Jamal E. Kharrat on 12/22/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import UIKit
import DominantColor

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var boxes: [UIView]!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage!

    // MARK: IBActions
    
    @IBAction func selectTapped(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func runBenchmarkTapped(sender: AnyObject) {
        if let image = image {
            let nValues: [Int] = [100, 1000, 2000, 5000, 10000]
            let CGImage = image.CGImage
            for n in nValues {
                let ns = dispatch_benchmark(5) {
                    dominantColorsInImage(CGImage, maxSampledPixels: n)
                    return
                }
                println("n = \(n) averaged \(ns/1000000) ms")
            }
        }
    }
    
    // MARK: ImagePicker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if let imageSelected = image {
            self.image = imageSelected
            imageView.image = imageSelected
            
            let colors = imageSelected.dominantColors()
            for box in boxes {
                box.backgroundColor = UIColor.clearColor()
            }
            for i in 0..<min(colors.count, boxes.count) {
                boxes[i].backgroundColor = colors[i]
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
}
