//
//  DominantColors.swift
//  DominantColor
//
//  Created by Indragie on 12/20/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#if os(OSX)
import Foundation
#elseif os(iOS)
import UIKit
#endif

// MARK: Bitmaps

private struct RGBAPixel {
    let r: UInt8
    let g: UInt8
    let b: UInt8
    let a: UInt8
}

extension RGBAPixel: Hashable {
    private var hashValue: Int {
        return (((Int(r) << 8) | Int(g)) << 8) | Int(b)
    }
}

private func ==(lhs: RGBAPixel, rhs: RGBAPixel) -> Bool {
    return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
}

private func createRGBAContext(width: UInt, height: UInt) -> CGContext {
    return CGBitmapContextCreate(
        nil,
        width,
        height,
        8,          // bits per component
        width * 4,  // bytes per row
        CGColorSpaceCreateDeviceRGB(),
        CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
    )
}

// Enumerates over all of the pixels in an RGBA bitmap context
// in the order that they are stored in memory, for faster access.
//
// From: https://www.mikeash.com/pyblog/friday-qa-2012-08-31-obtaining-and-interpreting-image-data.html
private func enumerateRGBAContext(context: CGContext, handler: (UInt, UInt, RGBAPixel) -> Void) {
    let (width, height) = (CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context))
    let data = unsafeBitCast(CGBitmapContextGetData(context), UnsafeMutablePointer<RGBAPixel>.self)
    for y in 0..<height {
        for x in 0..<width {
            handler(x, y, data[Int(x + y * width)])
        }
    }
}

// MARK: Conversions

private func RGBVectorToCGColor(rgbVector: INVector3) -> CGColor {
    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), [CGFloat(rgbVector.x), CGFloat(rgbVector.y), CGFloat(rgbVector.z), 1.0])
}

private extension RGBAPixel {
    func toRGBVector() -> INVector3 {
        return INVector3(
            x: Float(r) / Float(UInt8.max),
            y: Float(g) / Float(UInt8.max),
            z: Float(b) / Float(UInt8.max)
        )
    }
}

// MARK: Clustering

extension INVector3 : ClusteredType {}

// MARK: Main

public enum GroupingAccuracy {
    case Low        // CIE 76 - Euclidian distance
    case Medium     // CIE 94 - Perceptual non-uniformity corrections
    case High       // CIE 2000 - Additional corrections for neutral colors, lightness, chroma, and hue
}

struct DefaultParameterValues {
    static var maxSampledPixels: UInt = 1000
    static var accuracy: GroupingAccuracy = .Medium
    static var seed: UInt32 = 3571
}

public func dominantColorsInImage(
        image: CGImage,
        maxSampledPixels: UInt = DefaultParameterValues.maxSampledPixels,
        accuracy: GroupingAccuracy = DefaultParameterValues.accuracy,
        seed: UInt32 = DefaultParameterValues.seed
    ) -> [CGColor] {
    
    let (width, height) = (CGImageGetWidth(image), CGImageGetHeight(image))
    let (scaledWidth, scaledHeight) = scaledDimensionsForPixelLimit(maxSampledPixels, width, height)
    
    // Downsample the image if necessary, so that the total number of
    // pixels sampled does not exceed the specified maximum.
    let context = createRGBAContext(scaledWidth, scaledHeight)
    CGContextDrawImage(context, CGRect(x: 0, y: 0, width: Int(scaledWidth), height: Int(scaledHeight)), image)

    // Get the RGB colors from the bitmap context, ignoring any pixels
    // that have alpha transparency.
    // Also convert the colors to the LAB color space
    var labValues = [INVector3]()
    labValues.reserveCapacity(Int(scaledWidth * scaledHeight))
    
#if MEMOIZE
    let memoizedRGBToLAB: RGBAPixel -> INVector3 = memoize { IN_RGBToLAB($0.toRGBVector()) }
    enumerateRGBAContext(context) { (_, _, pixel) in
        if pixel.a == UInt8.max {
            labValues.append(memoizedRGBToLAB(pixel))
        }
    }
#else
    enumerateRGBAContext(context) { (_, _, pixel) in
        if pixel.a == UInt8.max {
            labValues.append(IN_RGBToLAB(pixel.toRGBVector()))
        }
    }
#endif // MEMOIZE
        
    // Cluster the colors using the k-means algorithm
    let k = selectKForElements(labValues)
    var clusters = kmeans(labValues, k, seed, distanceForAccuracy(accuracy))
    
    // Sort the clusters by size in descending order so that the
    // most dominant colors come first.
    clusters.sort { $0.size > $1.size }
    
    return clusters.map { RGBVectorToCGColor(IN_LABToRGB($0.centroid)) }
}

private func distanceForAccuracy(accuracy: GroupingAccuracy) -> (INVector3, INVector3) -> Float {
    switch accuracy {
    case .Low:
        return CIE76SquaredColorDifference
    case .Medium:
        return CIE94SquaredColorDifference()
    case .High:
        return CIE2000SquaredColorDifference()
    }
}

// Computes the proportionally scaled dimensions such that the
// total number of pixels does not exceed the specified limit.
private func scaledDimensionsForPixelLimit(limit: UInt, width: UInt, height: UInt) -> (UInt, UInt) {
    if (width * height > limit) {
        let ratio = Float(width) / Float(height)
        let maxWidth = sqrtf(ratio * Float(limit))
        return (UInt(maxWidth), UInt(Float(limit) / maxWidth))
    }
    return (width, height)
}

private func selectKForElements<T>(elements: [T]) -> Int {
    // Seems like a magic number...
    return 16
}
