//
//  ViewController.swift
//  Dominant Color iOS
//
//  Created by Jamal E. Kharrat on 12/22/14.
//  Copyright (c) 2014 indragie. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var box1: UIView!
    @IBOutlet weak var box2: UIView!
    @IBOutlet weak var box3: UIView!
    @IBOutlet weak var box4: UIView!
    @IBOutlet weak var box5: UIView!
    @IBOutlet weak var box6: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    @IBAction func selectTapped(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func runBenchmarkTapped(sender: AnyObject) {
        if let image = image {
            let nValues: [UInt] = [100, 1000, 2000, 5000, 10000]
            let CGImage = image.CGImage
            for n in nValues {
                let ns = dispatch_benchmark(5) {
                    dominantColorsInImage(CGImage, n, 98251)
                    return
                }
                println("n = \(n) averaged \(ns/1000000) ms")
            }
        }
        
    }
    
    // MARK: ImagePicker Delegate
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if let imageSelected = image {
            self.image = imageSelected
            imageView.image = imageSelected
            let CGImage = image.CGImage
            let colors = dominantColorsInImage(CGImage, 1000, 98251)
            let boxes = [box1, box2, box3, box4, box5, box6]
            
            for box in boxes {
                box.backgroundColor = UIColor.clearColor()
            }
            for i in 0..<min(countElements(colors), countElements(boxes)) {
                boxes[i].backgroundColor = UIColor(CGColor: colors[i])
            }
            
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
}

