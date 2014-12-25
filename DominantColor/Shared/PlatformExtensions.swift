//
//  PlatformExtensions.swift
//  DominantColor
//
//  Created by Indragie on 12/25/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#if os(OSX)
import Cocoa

public extension NSImage {
    public func dominantColors(
        maxSampledPixels: UInt = DefaultParameterValues.maxSampledPixels,
        accuracy: GroupingAccuracy = DefaultParameterValues.accuracy,
        seed: UInt32 = DefaultParameterValues.seed
    ) -> [NSColor] {
        let image = CGImageForProposedRect(nil, context: nil, hints: nil)!.takeUnretainedValue()
        let colors = dominantColorsInImage(image, maxSampledPixels: maxSampledPixels, accuracy: accuracy, seed: seed)
        return colors.map { NSColor(CGColor: $0) }
    }
}

#elseif os(iOS)
import UIKit

public extension UIImage {
    public func dominantColors(
        maxSampledPixels: UInt = DefaultParameterValues.maxSampledPixels,
        accuracy: GroupingAccuracy = DefaultParameterValues.accuracy,
        seed: UInt32 = DefaultParameterValues.seed
    ) -> [UIColor] {
        let colors = dominantColorsInImage(self.CGImage, maxSampledPixels: maxSampledPixels, accuracy: accuracy, seed: seed)
        return colors.map { UIColor(CGColor: $0) }
    }
}

#endif

