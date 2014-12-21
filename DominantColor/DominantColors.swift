//
//  DominantColors.swift
//  DominantColor
//
//  Created by Indragie on 12/20/14.
//  Copyright (c) 2014 indragie. All rights reserved.
//

import Foundation

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
        return CGColorCreateGenericRGB(CGFloat(r), CGFloat(g), CGFloat(b), 1.0)
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
    // Wikipedia suggests choosing k = sqrt(n/2) as a "rule of thumb"
    // http://en.wikipedia.org/wiki/Determining_the_number_of_clusters_in_a_data_set
    return Int(sqrt(Float(countElements(elements) / 2)))
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

// Threshold used for k-means algorithm
private let kmeansThreshold: Float = 0.1

public func dominantColorsInImage(image: CGImage, maxSampledPixels: UInt) -> [CGColor] {
    let (width, height) = (CGImageGetWidth(image), CGImageGetHeight(image))
    let dimensions = scaledDimensionsForPixelLimit(maxSampledPixels, width, height)
    
    // Downsample the image if necessary, so that the total number of
    // pixels sampled does not exceed the specified maximum.
    let context = createRGBAContext(dimensions)
    CGContextDrawImage(context, CGRect(x: 0, y: 0, width: Int(width), height: Int(height)), image)
    
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
    var clusters = kmeans(yuvColors, k, kmeansThreshold)
    
    // Sort the clusters by size in descending order so that the
    // most dominant colors come first.
    clusters.sort { $0.size > $1.size }
    
    return clusters.map { IN_YUVColorToRGBColor($0.centroid).toCGColor() }
}
