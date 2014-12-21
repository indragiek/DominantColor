//
//  RGBYUVConversion.h
//  DominantColor
//
//  Created by Indragie on 12/20/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

typedef struct {
    float r;
    float g;
    float b;
} IN_RGBColor;

typedef struct {
    float y;
    float u;
    float v;
} IN_YUVColor;

// All of these functions are implemented using GLKit by converting
// YUV color coordinates into 3-component vectors.
//
// These are implemented in C because the GLKit vector/matrix types
// are unions and Swift cannot yet work with unions.

IN_YUVColor IN_RGBColorToYUVColor(IN_RGBColor color);
IN_RGBColor IN_YUVColorToRGBColor(IN_YUVColor color);
float IN_YUVColorSquaredDistance(IN_YUVColor c1, IN_YUVColor c2);
IN_YUVColor IN_YUVColorSum(IN_YUVColor c1, IN_YUVColor c2);
IN_YUVColor IN_YUVColorDivideScalar(IN_YUVColor color, float scalar);
