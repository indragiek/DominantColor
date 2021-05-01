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

import simd

// MARK: Bitmaps

private struct RGBAPixel {
    let r: UInt8
    let g: UInt8
    let b: UInt8
    let a: UInt8
}

extension RGBAPixel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(r)
        hasher.combine(g)
        hasher.combine(b)
    }
}

private func ==(lhs: RGBAPixel, rhs: RGBAPixel) -> Bool {
    return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
}

private func createRGBAContext(_ width: Int, height: Int) -> CGContext {
    return CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,          // bits per component
        bytesPerRow: width * 4,  // bytes per row
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
    )!
}

// Enumerates over all of the pixels in an RGBA bitmap context
// in the order that they are stored in memory, for faster access.
//
// From: https://www.mikeash.com/pyblog/friday-qa-2012-08-31-obtaining-and-interpreting-image-data.html
private func enumerateRGBAContext(_ context: CGContext, handler: (Int, Int, RGBAPixel) -> Void) {
    let (width, height) = (context.width, context.height)
    let data = unsafeBitCast(context.data, to: UnsafeMutablePointer<RGBAPixel>.self)
    for y in 0..<height {
        for x in 0..<width {
            handler(x, y, data[Int(x + y * width)])
        }
    }
}

// MARK: Conversions

private func RGBVectorToCGColor(_ rgbVector: simd_float3) -> CGColor {
    return CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [CGFloat(rgbVector.x), CGFloat(rgbVector.y), CGFloat(rgbVector.z), 1.0])!
}

private extension RGBAPixel {
    func toRGBVector() -> simd_float3 {
        return simd_float3(
            Float(r) / Float(UInt8.max),
            Float(g) / Float(UInt8.max),
            Float(b) / Float(UInt8.max)
        )
    }
}

// MARK: Clustering

extension simd_float3 : ClusteredType {}

// MARK: Main

public enum GroupingAccuracy {
    case low        // CIE 76 - Euclidian distance
    case medium     // CIE 94 - Perceptual non-uniformity corrections
    case high       // CIE 2000 - Additional corrections for neutral colors, lightness, chroma, and hue
}

public struct DefaultParameterValues {
    public static var maxSampledPixels: Int = 1000
    public static var accuracy: GroupingAccuracy = .medium
    public static var seed: UInt64 = 3571
    public static var memoizeConversions: Bool = false
}

/**
Computes the dominant colors in an image

- parameter image:              The image
- parameter maxSampledPixels:   Maximum number of pixels to sample in the image. If
                           the total number of pixels in the image exceeds this
                           value, it will be downsampled to meet the constraint.
- parameter accuracy:           Level of accuracy to use when grouping similar colors.
                           Higher accuracy will come with a performance tradeoff.
- parameter seed:               Seed to use when choosing the initial points for grouping
                           of similar colors. The same seed is guaranteed to return
                           the same colors every time.
- parameter memoizeConversions: Whether to memoize conversions from RGB to the LAB color
                           space (used for grouping similar colors). Memoization
                           will only yield better performance for large values of
                           `maxSampledPixels` in images that are primarily comprised
                           of flat colors. If this information about the image is
                           not known beforehand, it is best to not memoize.

- returns: A list of dominant colors in the image sorted from most dominant to
          least dominant.
*/
public func dominantColorsInImage(
        _ image: CGImage,
        maxSampledPixels: Int = DefaultParameterValues.maxSampledPixels,
        accuracy: GroupingAccuracy = DefaultParameterValues.accuracy,
        seed: UInt64 = DefaultParameterValues.seed,
        memoizeConversions: Bool = DefaultParameterValues.memoizeConversions
    ) -> [CGColor] {
    
    let (width, height) = (image.width, image.height)
    let (scaledWidth, scaledHeight) = scaledDimensionsForPixelLimit(maxSampledPixels, width: width, height: height)
    
    // Downsample the image if necessary, so that the total number of
    // pixels sampled does not exceed the specified maximum.
    let context = createRGBAContext(scaledWidth, height: scaledHeight)
    context.draw(image, in: CGRect(x: 0, y: 0, width: Int(scaledWidth), height: Int(scaledHeight)))

    // Get the RGB colors from the bitmap context, ignoring any pixels
    // that have alpha transparency.
    // Also convert the colors to the LAB color space
    var labValues = [simd_float3]()
    labValues.reserveCapacity(Int(scaledWidth * scaledHeight))

    let RGBToLAB: (RGBAPixel) -> simd_float3 = {
        let f: (RGBAPixel) -> simd_float3 = { IN_RGBToLAB($0.toRGBVector()) }
        return memoizeConversions ? memoize(f) : f
    }()
    enumerateRGBAContext(context) { (_, _, pixel) in
        if pixel.a == UInt8.max {
            labValues.append(RGBToLAB(pixel))
        }
    }
    // Cluster the colors using the k-means algorithm
    let k = selectKForElements(labValues)
    var clusters = kmeans(labValues, k: k, seed: seed, distance: distanceForAccuracy(accuracy))

    // Sort the clusters by size in descending order so that the
    // most dominant colors come first.
    clusters.sort { $0.size > $1.size }

    return clusters.map { RGBVectorToCGColor(IN_LABToRGB($0.centroid)) }
}

private func distanceForAccuracy(_ accuracy: GroupingAccuracy) -> (simd_float3, simd_float3) -> Float {
    switch accuracy {
    case .low:
        return CIE76SquaredColorDifference
    case .medium:
        return CIE94SquaredColorDifference()
    case .high:
        return CIE2000SquaredColorDifference()
    }
}

// Computes the proportionally scaled dimensions such that the
// total number of pixels does not exceed the specified limit.
private func scaledDimensionsForPixelLimit(_ limit: Int, width: Int, height: Int) -> (Int, Int) {
    if (width * height > limit) {
        let ratio = Float(width) / Float(height)
        let maxWidth = sqrtf(ratio * Float(limit))
        return (Int(maxWidth), Int(Float(limit) / maxWidth))
    }
    return (width, height)
}

private func selectKForElements<T>(_ elements: [T]) -> Int {
    // Seems like a magic number...
    return 16
}
