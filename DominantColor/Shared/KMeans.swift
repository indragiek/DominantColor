//
//  KMeans.swift
//  DominantColor
//
//  Created by Indragie on 12/20/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import Darwin
import GameKit

// Represents a type that can be clustered using the k-means clustering
// algorithm.
protocol ClusteredType {
    // Used to compute average values to determine the cluster centroids.
    static func +(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Int) -> Self
    
    // Identity value such that x + identity = x. Typically the 0 vector.
    static var identity: Self { get }
}

struct Cluster<T : ClusteredType> {
    let centroid: T
    let size: Int
}

// k-means clustering algorithm from
// http://users.eecs.northwestern.edu/~wkliao/Kmeans/

func kmeans<T : ClusteredType>(
        _ points: [T],
        k: Int,
        seed: UInt64,
        distance: ((T, T) -> Float),
        threshold: Float = 0.0001
    ) -> [Cluster<T>] {
            
    let n = points.count
    assert(k <= n, "k cannot be larger than the total number of points")

    var centroids = points.randomValues(k, seed: seed)
    var memberships = [Int](repeating: -1, count: n)
    var clusterSizes = [Int](repeating: 0, count: k)
    
    var error: Float = 0
    var previousError: Float = 0
    
    repeat {
        error = 0
        var newCentroids = [T](repeating: T.identity, count: k)
        var newClusterSizes = [Int](repeating: 0, count: k)
        
        for i in 0..<n {
            let point = points[i]
            let clusterIndex = findNearestCluster(point, centroids: centroids, k: k, distance: distance)
            if memberships[i] != clusterIndex {
                error += 1
                memberships[i] = clusterIndex
            }
            newClusterSizes[clusterIndex] += 1
            newCentroids[clusterIndex] = newCentroids[clusterIndex] + point
        }
        for i in 0..<k {
            let size = newClusterSizes[i]
            if size > 0 {
                centroids[i] = newCentroids[i] / size
            }
        }
        
        clusterSizes = newClusterSizes
        previousError = error
    } while abs(error - previousError) > threshold
    
    return zip(centroids, clusterSizes).map { Cluster(centroid: $0, size: $1) }
}

private func findNearestCluster<T : ClusteredType>(_ point: T, centroids: [T], k: Int, distance: (T, T) -> Float) -> Int {
    var minDistance = Float.infinity
    var clusterIndex = 0
    for i in 0..<k {
        let distance = distance(point, centroids[i])
        if distance < minDistance {
            minDistance = distance
            clusterIndex = i
        }
    }
    return clusterIndex
}

private extension Array {
    func randomValues(_ num: Int, seed: UInt64) -> [Element] {
        if self.isEmpty {
            return self
        }
        let rs = GKMersenneTwisterRandomSource()
        rs.seed = seed

        let rd = GKRandomDistribution(randomSource: rs, lowestValue: 0, highestValue: self.count - 1)

        var indices = [Int]()
        indices.reserveCapacity(num)

        for _ in 0..<num {
            var random = 0
            repeat {
                random = rd.nextInt()
            } while indices.contains(random)
            indices.append(random)
        }

        return indices.map { self[$0] }
    }
}
