# Swift Perlin Noise

This is a simple implementation of Perlin noise in Swift, in 1D, 2D and 3D coordinate systems.




# How to make some noise!

First of all, you must decide which coordinate system to use, and create the object with a String as a seed (the seed should always create the same noise).

```swift
let perlin1D = Perlin1D(seed: "SeedGoesHere")
let perlin2D = Perlin2D(seed: "SeedGoesHere")
let perlin3D = Perlin3D(seed: "SeedGoesHere")
```

You can then fetch the data for each individual point in your coordinate system. It assumes that coordinates will increment in 1/50th

```swift
perlin2D.noise(x: 3/50)
perlin2D.noise(x: 3/50, y: 11/50)
perlin3D.noise(x: 3/50, y: 11/50, z: 42/50)
```

Should you want to process all of your points at once and then store them for faster access, you can set a range of points and it will return a matrix containing all of the noise values. You do not need to divide by 50 for this, it does it automatically. Perlin1D has the option of returning a 1 dimensional array, or a boolean matrix with 1s or 0s
```swift
let array1D = perlin1D.perlinArray(width: 100)

let mat1 = perlin1D.perlinBooleanMatrix(width: 100, height: 100)
let mat2 = perlin2D.perlinMatrix(width: 100, height: 100)
let mat3 = perlin3D.perlinMatrix(width: 100, height: 100, length: 100)
```

You can also use octaves to make your noise maps more natuaral. There are functions built in for doing this on individual points, and on whole matrices:

```swift
perlin1D.octaveNoise(x: 3/50, octaves: 6, persistence: 0.25)
perlin2D.octaveNoise(x: 3/50, y: 11/50, octaves: 6, persistence: 0.25)
perlin3D.octaveNoise(x: 3/50, y: 11/50, z: 42/50, octaves: 6, persistence: 0.25)

let array1D = perlin1D.octaveArray(width: 100, octaves: 6, persistance: 0.25)

let mat1 = perlin1D.octaveBooleanMatrix(width: 100, height: 100, octaves: 6, persistance: 0.25)
let mat2 = perlin2D.octaveMatrix(width: 100, height: 100, octaves: 6, persistance: 0.25)
let mat3 = perlin3D.octaveMatrix(width: 100, height: 100, length: 100, octaves: 6, persistance: 0.25)
```


An extra feature of the 1D and 2D coordinate systems is being able to turn your noise into UIImages to view how it looks. Note that the size of the image must be equal to the number of coordinates.

```swift
perlin1D.generateNoiseImage(size: CGSize(width: 100, height: 100), matrix: mat1) //mat1 is the boolean matrix, not the array
perlin2D.generateNoiseImage(size: CGSize(width: 100, height: 100), matrix: mat2) 
```

![Imgur](http://i.imgur.com/ve7wWDd.png)
![Imgur](http://i.imgur.com/TQxeIUW.png)
