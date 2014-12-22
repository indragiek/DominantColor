//
//  ColorSpaceConversion.h
//  DominantColor
//
//  Created by Indragie on 12/21/14.
//  Copyright (c) 2014 indragie. All rights reserved.
//

#import "INVector3.h"

// Simple SRGB <-> LAB conversion functions assuming a D65 illuminant
// with the standard 2° observer for CIE 1931.
INVector3 INSRGBToLAB(INVector3 srgbVector);
INVector3 INLABToSRGB(INVector3 labVector);
