//
//  KMeans.swift
//  DominantColor
//
//  Created by Indragie on 12/20/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import Darwin

// Represents a type that can be clustered using the k-means clustering
// algorithm.
public protocol ClusteredType {
    // Distance between two clustered objects. Typically, this is the
    // Euclidean distance between two vectors.
    func distance(to: Self) -> Float
    
    // `+` and `divideScalar` are used to compute average values to
    // determine the cluster centroids.
    func +(lhs: Self, rhs: Self) -> Self
    func divideScalar(scalar: Int) -> Self
    
    // Identity value such that x + identity = x. Typically the 0 vector.
    class var identity: Self { get }
}

public struct Cluster<T : ClusteredType> {
    let centroid: T
    let size: Int
}

// k-means clustering algorithm from
// http://users.eecs.northwestern.edu/~wkliao/Kmeans/

public func kmeans<T : ClusteredType>(objects: [T], k: Int, seed: Int, threshold: Float = 0.0001) -> [Cluster<T>] {
    let n = countElements(objects)
    assert(k <= n, "k cannot be larger than the total number of objects")

    var centroids = objects.randomValues(seed, count: k)
    var memberships = [Int](count: n, repeatedValue: -1)
    var clusterSizes = [Int](count: k, repeatedValue: 0)
    
    var error: Float = 0
    var previousError: Float = 0
    
    do {
        error = 0
        var newCentroids = [T](count: k, repeatedValue: T.identity)
        var newClusterSizes = [Int](count: k, repeatedValue: 0)
        
        for i in 0..<n {
            let object = objects[i]
            let clusterIndex = findNearestCluster(object, centroids, k)
            if memberships[i] != clusterIndex {
                error += 1
                memberships[i] = clusterIndex
            }
            newClusterSizes[clusterIndex]++
            newCentroids[clusterIndex] = newCentroids[clusterIndex] + object
        }
        for i in 0..<k {
            let size = newClusterSizes[i]
            if size > 0 {
                centroids[i] = newCentroids[i].divideScalar(size)
            }
        }
        
        clusterSizes = newClusterSizes
        previousError = error
    } while abs(error - previousError) > threshold
    
    return map(Zip2(centroids, clusterSizes)) { Cluster(centroid: $0, size: $1) }
}

private func findNearestCluster<T : ClusteredType>(object: T, centroids: [T], k: Int) -> Int {
    var minDistance = Float.infinity
    var clusterIndex = 0
    for i in 0..<k {
        let distance = object.distance(centroids[i])
        if distance < minDistance {
            minDistance = distance
            clusterIndex = i
        }
    }
    return clusterIndex
}

private func randomNumberInRange(range: Range<Int>) -> Int {
    let interval = range.endIndex - range.startIndex - 1
    let buckets = Int(RAND_MAX) / interval
    let limit = buckets * interval
    var r = 0
    do {
        r = Int(rand())
    } while r >= limit
    return range.startIndex + (r / buckets)
}

private extension Array {
    private func randomValues(seed: Int, count: Int) -> [T] {
        srand(UInt32(seed))
        
        var indices = [Int]()
        indices.reserveCapacity(count)
        let range = 0..<countElements(self)
        for i in 0..<count {
            var random = 0
            do {
                random = randomNumberInRange(range)
            } while contains(indices, random)
            indices.append(random)
        }

        return indices.map { self[$0] }
    }
}
