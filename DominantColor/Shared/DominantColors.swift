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

public func +(lhs: INVector3, rhs: INVector3) -> INVector3 {
    return INVector3Add(lhs, rhs)
}

extension INVector3 : ClusteredType {
    public func distance(to: INVector3) -> Float {
        return CIE2000SquaredColorDifference(self, to)
    }
    
    public func divideScalar(scalar: Int) -> INVector3 {
        return INVector3DivideScalar(self, Float(scalar))
    }
    
    public static var identity: INVector3 {
        return INVector3(x: 0, y: 0, z: 0)
    }
}

private func selectKForElements<T>(elements: [T]) -> Int {
    // Seems like a magic number...
    return 16
}

// MARK: Main

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

public func dominantColorsInImage(image: CGImage, maxSampledPixels: UInt, seed: Int) -> [CGColor] {
    let (width, height) = (CGImageGetWidth(image), CGImageGetHeight(image))
    let (scaledWidth, scaledHeight) = scaledDimensionsForPixelLimit(maxSampledPixels, width, height)
    
    // Downsample the image if necessary, so that the total number of
    // pixels sampled does not exceed the specified maximum.
    let context = createRGBAContext(scaledWidth, scaledHeight)
    CGContextDrawImage(context, CGRect(x: 0, y: 0, width: Int(scaledWidth), height: Int(scaledHeight)), image)
    
    var yuvColors = [INVector3]()
    yuvColors.reserveCapacity(Int(width * height))
    var cache = [UInt32:INVector3]()

    // Get the RGB colors from the bitmap context, ignoring any pixels
    // that have alpha transparency.
    // Also convert the colors to the LAB color space
    enumerateRGBAContext(context) { (_, _, pixel) in
        if pixel.a == UInt8.max {
            // HashValue will be the result of an OR op over the R, G, B values which are each 8 bytes
            // But 8 * 3 = 24, so align that on the next available byte size ie 32
            // So hashvalue will look like this: 00000000rrrrrrrrggggggggbbbbbbbb
            var hashValue = (UInt32(pixel.r) << 16) | (UInt32(pixel.g) << 8) | (UInt32(pixel.b) << 0)
            var labValue = cache[hashValue]
            
            if labValue == nil { // Cache miss
                labValue = IN_RGBToLAB(pixel.toRGBVector())
                cache[hashValue] = labValue
            }
            yuvColors.append(labValue!)
        }
    }

    // cluster the colors using the k-means algorithm
    let k = selectKForElements(yuvColors)
    var clusters = kmeans(yuvColors, k, seed)
    
    // Sort the clusters by size in descending order so that the
    // most dominant colors come first.
    clusters.sort { $0.size > $1.size }
    
    return clusters.map { RGBVectorToCGColor(IN_LABToRGB($0.centroid)) }
}
