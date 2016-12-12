# Swift Perlin Noise

This is a simple implementation of Perlin noise in Swift, in both 2D and 3D coordinate systems.




# How to make some noise!

First of all, you must decide which coordinate system to use, and create the object with a String as a seed (the seed should always create the same noise).

```swift
let perlin2D = Perlin2D(seed: "SeedGoesHere")
let perlin3D = Perlin3D(seed: "SeedGoesHere")
```

You can then fetch the data for each individual point in your coordinate system. It assumes that coordinates will increment in 1s

```swift
perlin2D.noise(x: 3, y: 11)
perlin3D.noise(x: 3, y: 11, z: 42)
```

Should you want to process all of your points at once and then store them for faster access, you can set a range of points and it will return a matrix containing all of the noise values

```swift
let mat1 = perlin2D.perlinMatrix(width: 100, height: 100)
let mat2 = perlin3D.perlinMatrix(width: 100, height: 100, length: 100)
```

You can also use octaves to make your noise maps more natuaral. There are functions built in for doing this on individual points, and on whole matrices:

```swift
perlin2D.octaveNoise(x: 3, y: 11, octaves: 6, persistence: 0.25)
perlin3D.octaveNoise(x: 3, y: 11, z: 42, octaves: 6, persistence: 0.25)

let mat1 = perlin2D.octaveMatrix(width: 100, height: 100, octaves: 6, persistance: 0.25)
let mat2 = perlin3D.octaveMatrix(width: 100, height: 100, length: 100, octaves: 6, persistance: 0.25)
```


An extra feature of the 2D coordinate system is being able to turn your noise into UIImages to view how it looks. Note that the size of the image must be equal to the number of coordinates.

```swift
perlin.generateNoiseImage(size: CGSize(width: 100, height: 100), matrix: mat1) 
```
