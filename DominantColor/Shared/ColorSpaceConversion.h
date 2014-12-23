//
//  ColorSpaceConversion.h
//  DominantColor
//
//  Created by Indragie on 12/21/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "INVector3.h"

// Simple RGB <-> LAB conversion functions assuming a D65 illuminant
// with the standard 2° observer for CIE 1931.

INVector3 IN_RGBToLAB(INVector3 rgbVector);
INVector3 IN_LABToRGB(INVector3 labVector);
