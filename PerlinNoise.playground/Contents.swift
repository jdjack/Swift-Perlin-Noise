//: Playground - noun: a place where people can play

import UIKit

//The seed can be any string
let perlin = Perlin2D(seed: "Hello, World")

perlin.noise(x: 3.01, y: 11.22) //Find noise for point
perlin.octaveNoise(x: 3.01, y: 11.22, octaves: 6, persistence: 0.25) //Find octaved noise for point

let mat1 = perlin.perlinMatrix(width: 100, height: 100) //Get the x,y matrix for 100 points in each axis
let mat2 = perlin.octaveMatrix(width: 100, height: 100, octaves: 6, persistance: 0.25)//Get the octaved x,y matrix for 100 points in each axis


//Images must be square i.e. 100x100, 200x200, 1729x1729
perlin.generateNoiseImage(size: CGSize(width: 100, height: 100), matrix: mat1) //Display the noise map

perlin.generateNoiseImage(size: CGSize(width: 100, height: 100), matrix: mat2) //Display the octaved noise map

perlin.generateLandImage(size: CGSize(width: 100, height: 100), matrix: mat1) //Example game map

perlin.generateLandImage(size: CGSize(width: 100, height: 100), matrix: mat2) //Example game map