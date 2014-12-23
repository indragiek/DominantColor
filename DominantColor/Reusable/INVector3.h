//
//  INVector3.h
//  DominantColor
//
//  Created by Indragie on 12/21/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <GLKit/GLKit.h>

// Wrapping GLKVector3 values in a struct so that it can be used from Swift.

typedef struct {
    float x;
    float y;
    float z;
} INVector3;

GLKVector3 INVector3ToGLKVector3(INVector3 vector);
INVector3 GLKVector3ToINVector3(GLKVector3 vector);

INVector3 INVector3Add(INVector3 v1, INVector3 v2);
INVector3 INVector3DivideScalar(INVector3 vector, float scalar);
