//: Playground - noun: a place where people can play

import UIKit

//The seed can be any string
let perlin = Perlin(seed: "Test")

//Images must be square i.e. 100x100, 200x200, 1729x1729
perlin.generateNoiseImage(size: CGSize(width: 200, height: 200))
perlin.generateLandImage(size: CGSize(width: 200, height: 200))