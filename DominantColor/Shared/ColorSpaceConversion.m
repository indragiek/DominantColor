//
//  ColorSpaceConversion.m
//  DominantColor
//
//  Created by Indragie on 12/21/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "ColorSpaceConversion.h"

#pragma mark - RGB

static GLKVector3 RGBToSRGB(GLKVector3 rgbVector) {
#if TARGET_OS_IPHONE
    // sRGB is the native device color space on iOS, no conversion is required.
    return rgbVector;
#else
    NSColor *rgbColor = [NSColor colorWithDeviceRed:rgbVector.x green:rgbVector.y blue:rgbVector.z alpha:1.0];
    NSColor *srgbColor = [rgbColor colorUsingColorSpace:NSColorSpace.sRGBColorSpace];
    return GLKVector3Make(srgbColor.redComponent, srgbColor.greenComponent, srgbColor.blueComponent);
#endif
}

static GLKVector3 SRGBToRGB(GLKVector3 srgbVector) {
#if TARGET_OS_IPHONE
    // sRGB is the native device color space on iOS, no conversion is required.
    return srgbVector;
#else
    const CGFloat components[4] = { srgbVector.x, srgbVector.y, srgbVector.z, 1.0 };
    NSColor *srgbColor = [NSColor colorWithColorSpace:NSColorSpace.sRGBColorSpace components:components count:4];
    NSColor *rgbColor = [srgbColor colorUsingColorSpace:NSColorSpace.deviceRGBColorSpace];
    return GLKVector3Make(rgbColor.redComponent, rgbColor.greenComponent, rgbColor.blueComponent);
#endif
}

#pragma mark - SRGB
// http://en.wikipedia.org/wiki/SRGB#Specification_of_the_transformation

static GLKVector3 SRGBToLinearSRGB(GLKVector3 srgbVector) {
    float (^f)(float) = ^float (float c) {
        if (c <= 0.04045f) {
            return c / 12.92f;
        } else {
            return powf((c + 0.055f) / 1.055f, 2.4f);
        }
    };
    return GLKVector3Make(f(srgbVector.x), f(srgbVector.y), f(srgbVector.z));
}

static GLKVector3 LinearSRGBToSRGB(GLKVector3 lSrgbVector) {
    float (^f)(float) = ^float (float c) {
        if (c <= 0.0031308f) {
            return c * 12.92f;
        } else {
            return (1.055f * powf(c, 1.f / 2.4f)) - 0.055f;
        }
    };
    return GLKVector3Make(f(lSrgbVector.x), f(lSrgbVector.y), f(lSrgbVector.z));
}

#pragma mark - XYZ (CIE 1931)
// http://en.wikipedia.org/wiki/CIE_1931_color_space#Construction_of_the_CIE_XYZ_color_space_from_the_Wright.E2.80.93Guild_data

static const GLKMatrix3 LinearSRGBToXYZMatrix = (GLKMatrix3){
    0.4124f, 0.2126f, 0.0193f,
    0.3576f, 0.7152f, 0.1192f,
    0.1805f, 0.0722f, 0.9505f
};

static GLKVector3 LinearSRGBToXYZ(GLKVector3 linearSrgbVector) {
    const GLKVector3 unscaledXYZVector = GLKMatrix3MultiplyVector3(LinearSRGBToXYZMatrix, linearSrgbVector);
    return GLKVector3MultiplyScalar(unscaledXYZVector, 100.f);
}

static const GLKMatrix3 XYZToLinearSRGBMatrix = (GLKMatrix3){
    3.2406f, -0.9689f, 0.0557f,
    -1.5372f, 1.8758f, -0.2040f,
    -0.4986f, 0.0415f, 1.0570f
};

static GLKVector3 XYZToLinearSRGB(GLKVector3 xyzVector) {
    const GLKVector3 scaledXYZVector = GLKVector3DivideScalar(xyzVector, 100.f);
    return GLKMatrix3MultiplyVector3(XYZToLinearSRGBMatrix, scaledXYZVector);
}

#pragma mark - LAB
// http://en.wikipedia.org/wiki/Lab_color_space#CIELAB-CIEXYZ_conversions

static GLKVector3 XYZToLAB(GLKVector3 xyzVector, GLKVector3 tristimulus) {
    float (^f)(float) = ^float (float t) {
        if (t > powf(6.f / 29.f, 3.f)) {
            return powf(t, 1.f / 3.f);
        } else {
            return ((1.f / 3.f) * powf(29.f / 6.f, 2.f) * t) + (4.f / 29.f);
        }
    };
    const float fx = f(xyzVector.x / tristimulus.x);
    const float fy = f(xyzVector.y / tristimulus.y);
    const float fz = f(xyzVector.z / tristimulus.z);
    
    const float l = (116.f * fy) - 16.f;
    const float a = 500 * (fx - fy);
    const float b = 200 * (fy - fz);
    
    return GLKVector3Make(l, a, b);
}

static GLKVector3 LABToXYZ(GLKVector3 labVector, GLKVector3 tristimulus) {
    float (^f)(float) = ^float (float t) {
        if (t > (6.f / 29.f)) {
            return powf(t, 3.f);
        } else {
            return 3.f * powf(6.f / 29.f, 2.f) * (t - (4.f / 29.f));
        }
    };
    const float c = (1.f / 116.f) * (labVector.x + 16.f);
    
    const float y = tristimulus.y * f(c);
    const float x = tristimulus.x * f(c + ((1.f / 500.f) * labVector.y));
    const float z = tristimulus.z * f(c - ((1.f / 200.f) * labVector.z));
    
    return GLKVector3Make(x, y, z);
}

#pragma mark - Public

// From http://www.easyrgb.com/index.php?X=MATH&H=15#text15
static const GLKVector3 D65Tristimulus = (GLKVector3){ 95.047f, 100.f, 108.883f };

INVector3 IN_RGBToLAB(INVector3 rgbVector) {
    const GLKVector3 gVector = INVector3ToGLKVector3(rgbVector);
    const GLKVector3 srgbVector = RGBToSRGB(gVector);
    const GLKVector3 lSrgbVector = SRGBToLinearSRGB(srgbVector);
    const GLKVector3 xyzVector = LinearSRGBToXYZ(lSrgbVector);
    const GLKVector3 labVector = XYZToLAB(xyzVector, D65Tristimulus);
    return GLKVector3ToINVector3(labVector);
}

INVector3 IN_LABToRGB(INVector3 labVector) {
    const GLKVector3 gVector = INVector3ToGLKVector3(labVector);
    const GLKVector3 xyzVector = LABToXYZ(gVector, D65Tristimulus);
    const GLKVector3 lSrgbVector = XYZToLinearSRGB(xyzVector);
    const GLKVector3 srgbVector = LinearSRGBToSRGB(lSrgbVector);
    const GLKVector3 rgbVector = SRGBToRGB(srgbVector);
    return GLKVector3ToINVector3(rgbVector);
}
