//
//  Memoization.swift
//  DominantColor
//
//  Created by Emmanuel Odeke on 2014-12-25.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

func memoize<T: Hashable, U>(_ f: @escaping (T) -> U) -> (T) -> U {
    var cache = [T : U]()
    
    return { key in
        var value = cache[key]
        if value == nil {
            value = f(key)
            cache[key] = value
        }
        return value!
    }
}

