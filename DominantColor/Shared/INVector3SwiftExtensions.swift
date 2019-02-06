//
//  INVector3SwiftExtensions.swift
//  DominantColor
//
//  Created by Indragie on 12/24/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import GLKit

extension GLKVector3 {
    func unpack() -> (Float, Float, Float) {
        return (x, y, z)
    }
    
    static var identity: GLKVector3 {
        return GLKVector3Make(0, 0, 0)
    }

    static func +(lhs: GLKVector3, rhs: GLKVector3) -> GLKVector3 {
        return GLKVector3Make(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func /(lhs: GLKVector3, rhs: Float) -> GLKVector3 {
        return GLKVector3Make(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }

    static func /(lhs: GLKVector3, rhs: Int) -> GLKVector3 {
        return lhs / Float(rhs)
    }
}
