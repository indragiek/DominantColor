//
//  INVector3SwiftExtensions.swift
//  DominantColor
//
//  Created by Indragie on 12/24/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

extension INVector3 {
    func unpack() -> (Float, Float, Float) {
        return (x, y, z)
    }
    
    static var identity: INVector3 {
        return INVector3(x: 0, y: 0, z: 0)
    }
}

func +(lhs: INVector3, rhs: INVector3) -> INVector3 {
    return INVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}

func /(lhs: INVector3, rhs: Float) -> INVector3 {
    return INVector3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

func /(lhs: INVector3, rhs: Int) -> INVector3 {
    return lhs / Float(rhs)
}
