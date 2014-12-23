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

private extension IN_RGBColor {
    func toCGColor() -> CGColorRef {
        let components = [CGFloat(r), CGFloat(g), CGFloat(b), CGFloat(1.0)]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let CGColor    = CGColorCreate(colorSpace, components);
        return CGColor
    }
}

private extension RGBAPixel {
    func toRGBColor() -> IN_RGBColor {
        return IN_RGBColor(
            r: Float(r) / Float(UInt8.max),
            g: Float(g) / Float(UInt8.max),
            b: Float(b) / Float(UInt8.max)
        )
    }
}

// MARK: Clustering

public func +(lhs: IN_YUVColor, rhs: IN_YUVColor) -> IN_YUVColor {
    return IN_YUVColorSum(lhs, rhs)
}

extension IN_YUVColor : ClusteredType {
    public func distance(to: IN_YUVColor) -> Float {
        return IN_YUVColorSquaredDistance(self, to)
    }
    
    public func divideScalar(scalar: Int) -> IN_YUVColor {
        return IN_YUVColorDivideScalar(self, Float(scalar))
    }
    
    public static var identity: IN_YUVColor {
        return IN_YUVColor(y: 0, u: 0, v: 0)
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
    
    // Get the RGB colors from the bitmap context, ignoring any pixels
    // that have alpha transparency.
    var colors = [IN_RGBColor]()
    colors.reserveCapacity(Int(width * height))
    enumerateRGBAContext(context) { (_, _, pixel) in
        if pixel.a == UInt8.max {
            colors.append(pixel.toRGBColor())
        }
    }
    
    // Use the k-means clustering algorithm to cluster the colors
    // (converted to the YUV color space)
    let yuvColors = colors.map { IN_RGBColorToYUVColor($0) }
    let k = selectKForElements(yuvColors)
    var clusters = kmeans(yuvColors, k, seed)
    
    // Sort the clusters by size in descending order so that the
    // most dominant colors come first.
    clusters.sort { $0.size > $1.size }
    
    return clusters.map { IN_YUVColorToRGBColor($0.centroid).toCGColor() }
}
