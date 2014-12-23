//
//  INVector3.c
//  DominantColor
//
//  Created by Indragie on 12/21/14.
//  Copyright (c) 2014 indragie. All rights reserved.
//

#import "INVector3.h"

GLKVector3 INVector3ToGLKVector3(INVector3 vector) {
    return GLKVector3Make(vector.x, vector.y, vector.z);
}

INVector3 GLKVector3ToINVector3(GLKVector3 vector) {
    return (INVector3){ vector.x, vector.y, vector.z };
}

INVector3 INVector3Add(INVector3 v1, INVector3 v2) {
    return GLKVector3ToINVector3(GLKVector3Add(INVector3ToGLKVector3(v1), INVector3ToGLKVector3(v2)));
}

INVector3 INVector3DivideScalar(INVector3 vector, float scalar) {
    return GLKVector3ToINVector3(GLKVector3DivideScalar(INVector3ToGLKVector3(vector), scalar));
}
