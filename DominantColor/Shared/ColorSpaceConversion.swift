//
//  ColorSpaceConversion.swift
//  DominantColor
//
//  Created by Jernej Strasner on 2/5/19.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

import simd

// MARK: - RGB

func RGBToSRGB(_ rgbVector: simd_float3) -> simd_float3 {
    #if os(iOS)
    return rgbVector
    #elseif os(OSX)
    let rgbColor = NSColor(deviceRed: CGFloat(rgbVector.x), green: CGFloat(rgbVector.y), blue: CGFloat(rgbVector.z), alpha: 1.0)
    guard let srgbColor = rgbColor.usingColorSpace(.sRGB) else {
        fatalError("Could not convert color space")
    }
    return simd_float3(Float(srgbColor.redComponent), Float(srgbColor.greenComponent), Float(srgbColor.blueComponent))
    #endif
}

func SRGBToRGB(_ srgbVector: simd_float3) -> simd_float3 {
    #if os(iOS)
    return srgbVector
    #elseif os(OSX)
    let components: [CGFloat] = [CGFloat(srgbVector.x), CGFloat(srgbVector.y), CGFloat(srgbVector.z), 1.0]
    let srgbColor = NSColor(colorSpace: .sRGB, components: components, count: 4)
    guard let rgbColor = srgbColor.usingColorSpace(.deviceRGB) else {
        fatalError("Could not convert color space")
    }
    return simd_float3(Float(rgbColor.redComponent), Float(rgbColor.greenComponent), Float(rgbColor.blueComponent))
    #endif
}

// MARK: - SRGB

func SRGBToLinearSRGB(_ srgbVector: simd_float3) -> simd_float3 {
    func f(_ c: Float) -> Float {
        if (c <= 0.04045) {
            return c / 12.92
        } else {
            return powf((c + 0.055) / 1.055, 2.4)
        }
    }
    return simd_float3(f(srgbVector.x), f(srgbVector.y), f(srgbVector.z))
}

func LinearSRGBToSRGB(_ lSrgbVector: simd_float3) -> simd_float3 {
    func f(_ c: Float) -> Float {
        if (c <= 0.0031308) {
            return c * 12.92
        } else {
            return (1.055 * powf(c, 1.0 / 2.4)) - 0.055
        }
    };
    return simd_float3(f(lSrgbVector.x), f(lSrgbVector.y), f(lSrgbVector.z));
}

// MARK: - XYZ (CIE 1931)
// http://en.wikipedia.org/wiki/CIE_1931_color_space#Construction_of_the_CIE_XYZ_color_space_from_the_Wright.E2.80.93Guild_data

let LinearSRGBToXYZMatrix = simd_float3x3([
    SIMD3(0.4124, 0.2126, 0.0193),
    SIMD3(0.3576, 0.7152, 0.1192),
    SIMD3(0.1805, 0.0722, 0.9505)
])

func LinearSRGBToXYZ(_ linearSrgbVector: simd_float3) -> simd_float3 {
    let unscaledXYZVector = LinearSRGBToXYZMatrix * linearSrgbVector
    return unscaledXYZVector * 100.0
}

let XYZToLinearSRGBMatrix = simd_float3x3([
    SIMD3(3.2406, -0.9689, 0.0557),
    SIMD3(-1.5372, 1.8758, -0.2040),
    SIMD3(-0.4986, 0.0415, 1.0570)
])

func XYZToLinearSRGB(_ xyzVector: simd_float3) -> simd_float3 {
    let scaledXYZVector = xyzVector / 100.0
    return XYZToLinearSRGBMatrix * scaledXYZVector
}


// MARK: - LAB
// http://en.wikipedia.org/wiki/Lab_color_space#CIELAB-CIEXYZ_conversions

func XYZToLAB(_ xyzVector: simd_float3, _ tristimulus: simd_float3) -> simd_float3 {
    func f(_ t: Float) -> Float {
        if (t > powf(6.0 / 29.0, 3.0)) {
            return powf(t, 1.0 / 3.0)
        } else {
            return ((1.0 / 3.0) * powf(29.0 / 6.0, 2.0) * t) + (4.0 / 29.0)
        }
    };
    let fx = f(xyzVector.x / tristimulus.x)
    let fy = f(xyzVector.y / tristimulus.y)
    let fz = f(xyzVector.z / tristimulus.z)

    let l = (116.0 * fy) - 16.0
    let a = 500 * (fx - fy)
    let b = 200 * (fy - fz)

    return simd_float3(l, a, b)
}

func LABToXYZ(_ labVector: simd_float3, _ tristimulus: simd_float3) -> simd_float3 {
    func f(_ t: Float) -> Float {
        if (t > (6.0 / 29.0)) {
            return powf(t, 3.0)
        } else {
            return 3.0 * powf(6.0 / 29.0, 2.0) * (t - (4.0 / 29.0))
        }
    };
    let c = (1.0 / 116.0) * (labVector.x + 16.0)

    let y = tristimulus.y * f(c)
    let x = tristimulus.x * f(c + ((1.0 / 500.0) * labVector.y))
    let z = tristimulus.z * f(c - ((1.0 / 200.0) * labVector.z))

    return simd_float3(x, y, z)
}

// MARK: - Public

// From http://www.easyrgb.com/index.php?X=MATH&H=15#text15
let D65Tristimulus = simd_float3(5.047, 100.0, 108.883)

func IN_RGBToLAB(_ gVector: simd_float3) -> simd_float3 {
    let srgbVector = RGBToSRGB(gVector)
    let lSrgbVector = SRGBToLinearSRGB(srgbVector)
    let xyzVector = LinearSRGBToXYZ(lSrgbVector)
    let labVector = XYZToLAB(xyzVector, D65Tristimulus)
    return labVector
}

func IN_LABToRGB(_ gVector: simd_float3) -> simd_float3 {
    let xyzVector = LABToXYZ(gVector, D65Tristimulus)
    let lSrgbVector = XYZToLinearSRGB(xyzVector)
    let srgbVector = LinearSRGBToSRGB(lSrgbVector)
    let rgbVector = SRGBToRGB(srgbVector)
    return rgbVector
}
