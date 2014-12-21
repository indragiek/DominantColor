//
//  RGBYUVConversion.c
//  DominantColor
//
//  Created by Indragie on 12/20/14.
//  Copyright (c) 2014 indragie. All rights reserved.
//

#import "RGBYUVConversion.h"
#import <GLKit/GLKit.h>

static GLKVector3 YUVColorToVector(IN_YUVColor color) {
    return GLKVector3Make(color.y, color.u, color.v);
}

static IN_YUVColor VectorToYUVColor(GLKVector3 vector) {
    return (IN_YUVColor){vector.x, vector.y, vector.z};
}

static GLKVector3 RGBColorToVector(IN_RGBColor color) {
    return GLKVector3Make(color.r, color.g, color.b);
}

static IN_RGBColor VectorToRGBColor(GLKVector3 vector) {
    return (IN_RGBColor){vector.x, vector.y, vector.z};
}

IN_YUVColor IN_RGBColorToYUVColor(IN_RGBColor color) {
    const GLKMatrix3 yuvConversionMatrix = GLKMatrix3Make(
        0.299f, -0.14713f, 0.615f,
        0.587f, -0.28886f, -0.51499f,
        0.114f, 0.436f, -0.10001f
    );
    const GLKVector3 rgbVector = RGBColorToVector(color);
    const GLKVector3 yuvVector = GLKMatrix3MultiplyVector3(yuvConversionMatrix, rgbVector);
    return VectorToYUVColor(yuvVector);
}

IN_RGBColor IN_YUVColorToRGBColor(IN_YUVColor yuv) {
    const GLKMatrix3 rgbConversionMatrix = GLKMatrix3Make(
        1.f, 1.f, 1.f,
        0.f, -0.39465f, 2.03211f,
        1.13983f, -0.58060f, 0.f
    );
    const GLKVector3 yuvVector = YUVColorToVector(yuv);
    const GLKVector3 rgbVector = GLKMatrix3MultiplyVector3(rgbConversionMatrix, yuvVector);
    return VectorToRGBColor(rgbVector);
}

float IN_YUVColorSquaredDistance(IN_YUVColor c1, IN_YUVColor c2) {
    return powf(c2.y - c1.y, 2.f) + powf(c2.u - c1.u, 2.f) + powf(c2.v - c1.v, 2.f);
}

IN_YUVColor IN_YUVColorSum(IN_YUVColor c1, IN_YUVColor c2) {
    return (IN_YUVColor){c1.y + c2.y, c1.u + c2.u, c1.v + c2.v};
}

IN_YUVColor IN_YUVColorDivideScalar(IN_YUVColor color, float scalar) {
    return (IN_YUVColor){color.y / scalar, color.u / scalar, color.v / scalar};
}
