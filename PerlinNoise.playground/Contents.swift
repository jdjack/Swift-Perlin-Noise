import UIKit



// ------ Perlin 1D ------

let perlin1 = Perlin1D(seed: "Hello, World")

perlin1.noise(x: 21/50)
perlin1.octaveNoise(x: 21/50, octaves: 6, persistence: 0.25)

let mat11 = perlin1.perlinBooleanMatrix(width: 200, height: 200)
let mat12 = perlin1.octaveBooleanMatrix(width: 200, height: 200, octaves: 6, persistance: 0.3)

perlin1.generateNoiseImage(size: CGSize(width: 200, height: 200), matrix: mat11)


perlin1.generateNoiseImage(size: CGSize(width: 200, height: 200), matrix: mat12)





// ------ Perlin 2D ------

//The seed can be any string
let perlin = Perlin2D(seed: "Hello, World")

perlin.noise(x: 3/50, y: 11/50) //Find noise for point
perlin.octaveNoise(x: 3/50, y: 11/50, octaves: 6, persistence: 0.25) //Find octaved noise for point

let mat21 = perlin.perlinMatrix(width: 200, height: 200) //Get the x,y matrix for 200 points in each axis
let mat22 = perlin.octaveMatrix(width: 200, height: 200, octaves: 6, persistance: 0.25)//Get the octaved x,y matrix for 200 points in each axis


//Images must be square i.e. 100x100, 200x200, 1729x1729
perlin.generateNoiseImage(size: CGSize(width: 200, height: 200), matrix: mat21) //Display the noise map

perlin.generateNoiseImage(size: CGSize(width: 200, height: 200), matrix: mat22) //Display the octaved noise map

perlin.generateLandImage(size: CGSize(width: 200, height: 200), matrix: mat21) //Example game map

perlin.generateLandImage(size: CGSize(width: 200, height: 200), matrix: mat22) //Example game map







// ------ Perlin 3D ------


//The seed can be any string
let perlin3 = Perlin3D(seed: "Hello, World")

//Same as above with a 3rd dimension
perlin3.noise(x: 3/50, y: 11/50, z: 42/50)
perlin3.octaveNoise(x: 3/50, y: 11/50, z: 42/50, octaves: 6, persistence: 0.25)


let mat3 = perlin3.perlinMatrix(width: 10, height: 10, length: 10)
let mat4 = perlin3.octaveMatrix(width: 10, height: 10, length: 10, octaves: 6, persistance: 0.25)


//   x  y  z
mat3[3][2][1]










