//
//  ColorSpaceConversion.m
//  DominantColor
//
//  Created by Indragie on 12/21/14.
//  Copyright (c) 2014 indragie. All rights reserved.
//

#import "ColorSpaceConversion.h"

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
    return GLKMatrix3MultiplyVector3(LinearSRGBToXYZMatrix, linearSrgbVector);
}

static const GLKMatrix3 XYZToLinearSRGBMatrix = (GLKMatrix3){
    3.2406f, -0.9689f, 0.0557f,
    -1.5372f, 1.8758f, -0.2040f,
    -0.4986f, 0.0415f, 1.0570f
};

static GLKVector3 XYZToLinearSRGB(GLKVector3 xyzVector) {
    return GLKMatrix3MultiplyVector3(XYZToLinearSRGBMatrix, xyzVector);
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
    const float x = tristimulus.x * f(c + ((1.f / 500.f) * tristimulus.y));
    const float z = tristimulus.z * f(c - ((1.f / 200.f) * tristimulus.z));
    
    return GLKVector3Make(x, y, z);
}

#pragma mark - Public

// From http://www.easyrgb.com/index.php?X=MATH&H=15#text15
static const GLKVector3 D65Tristimulus = (GLKVector3){ 95.047f, 100.f, 108.883f };

INVector3 INSRGBToLAB(INVector3 srgbVector) {
    const GLKVector3 gVector = INVector3ToGLKVector3(srgbVector);
    const GLKVector3 lSrgbVector = SRGBToLinearSRGB(gVector);
    const GLKVector3 xyzVector = LinearSRGBToXYZ(lSrgbVector);
    const GLKVector3 labVector = XYZToLAB(xyzVector, D65Tristimulus);
    return GLKVector3ToINVector3(labVector);
}

INVector3 INLABToSRGB(INVector3 labVector) {
    const GLKVector3 gVector = INVector3ToGLKVector3(labVector);
    const GLKVector3 xyzVector = LABToXYZ(gVector, D65Tristimulus);
    const GLKVector3 lSrgbVector = XYZToLinearSRGB(xyzVector);
    const GLKVector3 srgbVector = LinearSRGBToSRGB(lSrgbVector);
    return GLKVector3ToINVector3(srgbVector);
}
