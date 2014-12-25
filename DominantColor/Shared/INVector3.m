//
//  INVector3.c
//  DominantColor
//
//  Created by Indragie on 12/21/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "INVector3.h"

GLKVector3 INVector3ToGLKVector3(INVector3 vector) {
    return GLKVector3Make(vector.x, vector.y, vector.z);
}

INVector3 GLKVector3ToINVector3(GLKVector3 vector) {
    return (INVector3){ vector.x, vector.y, vector.z };
}
