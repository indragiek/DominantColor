//
//  DragAndDropImageView.swift
//  DominantColor
//
//  Created by Indragie on 12/19/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import Cocoa

@objc protocol DragAndDropImageViewDelegate {
    func dragAndDropImageView(imageView: DragAndDropImageView, droppedImage image: NSImage?)
}

class DragAndDropImageView: NSImageView {
    @IBOutlet weak var delegate: DragAndDropImageViewDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSFilenamesPboardType, NSTIFFPboardType])
    }
    
    // MARK: NSDraggingDestination
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let pasteboard = sender.draggingPasteboard()
        if let data = pasteboard.dataForType(NSTIFFPboardType) {
            return .Copy
        } else if let files = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] {
            let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, files[0].pathExtension, nil).takeRetainedValue()
            return (UTTypeConformsTo(UTI, kUTTypeImage) == 1) ? .Copy : .None
        }
        return .None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()
        if let data = pasteboard.dataForType(NSTIFFPboardType) {
            self.delegate?.dragAndDropImageView(self, droppedImage: NSImage(data: data))
        } else if let files = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] {
            self.delegate?.dragAndDropImageView(self, droppedImage: NSImage(contentsOfFile: files[0]))
        }
        return true
    }
}
