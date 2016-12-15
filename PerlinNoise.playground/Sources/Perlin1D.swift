import UIKit

public class Perlin1D: NSObject {
    var permutation:[Int] = []
    
    
    public init(seed: String) {
        
        let hash = seed.hash
        
        srand48(hash)
        
        for _ in 0..<512 {
            //Create the permutations to pick from using a seed so you can recreate the map
            permutation.append(Int(drand48() * 255))
        }
    }
    
    
    func lerp(a:CGFloat, b:CGFloat, x:CGFloat) -> CGFloat {
        return a + x * (b - a) //This interpolates between two points with a weight x
    }
    
    func fade(t:CGFloat) -> CGFloat {
        return t * t * t * (t * (t * 6 - 15) + 10) //This is the smoothing function for Perlin noise
    }
    
    func grad(hash:Int, x:CGFloat) -> CGFloat {
        
        //This takes a hash (a number from 0 - 5) generated from the random permutations and returns a random
        //operation for the node to offset
        
        switch hash & 1 {
        case 0:
            return x
        case 1:
            return -x
        default:
            print("ERROR")
            return 0
        }
        
        
    }
    
    func fastfloor(x:CGFloat) -> Int {
        return x > 0 ? Int(x) : Int(x-1)
    }
    
    public func noise(x:CGFloat) -> CGFloat {
        
        //Find the unit grid cell containing the point
        var xi = fastfloor(x: x)
        
        //This is the other bound of the unit square
        let xf:CGFloat = x - CGFloat(xi)
        
        //Wrap the ints around 255
        xi = xi & 255
        
        //These are offset values for interpolation
        let u = fade(t: xf)
        
        
        //These are the 2 possible permutations so we get the perm value for each
        let a = permutation[xi]
        let b = permutation[xi + 1]
        
        
        //Lerp a and b
        let ab = lerp(a: grad(hash: a, x: xf), b: grad(hash: b, x: xf - 1), x: u)
        
        
        
        
        //We return the value + 1 / 2 to remove any negatives.
        return (ab + 1) / 2
    }
    
    
    public func octaveNoise(x:CGFloat, octaves:Int, persistence:CGFloat) -> CGFloat {
        
        //This takes several perlin readings (n octaves) and merges them into one map
        var total:CGFloat = 0
        var frequency: CGFloat = 1
        var amplitude: CGFloat = 1
        var maxValue: CGFloat = 0
        
        //We sum the total and divide by the max at the end to normalise
        for _ in 0..<octaves {
            total += noise(x: x * frequency) * amplitude
            
            maxValue += amplitude
            
            //This is taken from recomendations on values
            amplitude *= persistence
            frequency *= 2
        }
        
        //print(max)
        
        return total/maxValue
    }
    
    public func perlinArray(width:Int) -> [CGFloat] {
        
        var map:[CGFloat] = []
        
        
        for x in (0...width) {
            
            let cx:CGFloat = CGFloat(x)/50
            let p = noise(x: cx)
            map.append(p)
        }
        
        return map
        
    }
    
    public func octaveArray(width:Int, octaves:Int, persistance:CGFloat) -> [CGFloat] {
        
        var map:[CGFloat] = []
        
        
        for x in (0...width) {
            
            let cx:CGFloat = CGFloat(x)/50
            let p = octaveNoise(x: cx, octaves: octaves, persistence: persistance)
            map.append(p)
        }
        
        return map
        
    }
    
    
    public func perlinBooleanMatrix(width:Int, height: Int) -> [[CGFloat]] {
        
        let map = perlinArray(width: width)
        
        var mat:[[CGFloat]] = []
        
        for (x, val) in map.enumerated() {
            mat.append([])
            
            for y in (0...height) {
                
                if CGFloat(y) < CGFloat(height) * val {
                    mat[x].append(0)
                } else {
                    mat[x].append(1)
                }
                
            }
        }
        
        return mat
    }
    
    
    public func octaveBooleanMatrix(width:Int, height: Int, octaves:Int, persistance:CGFloat) -> [[CGFloat]] {
        
        let map = octaveArray(width: width, octaves: octaves, persistance: persistance)
        
        var mat:[[CGFloat]] = []
        
        for (x, val) in map.enumerated() {
            
            mat.append([])
            
            for y in (0...height) {
                
                if CGFloat(y) < CGFloat(height) * val {
                    mat[x].append(0)
                } else {
                    mat[x].append(1)
                }
                
            }
        }
        
        mat[0][10] = 1
        
        return mat
        
        
    }
    
    
    public func generateNoiseImage(size:CGSize, matrix:[[CGFloat]]) -> UIImage {
        
        
        let width = Int(size.width)
        let height = Int(size.height)
        
        //This times how long it takes to render, useful for testing its limits
        let startTime = CFAbsoluteTimeGetCurrent();
        
        //Create an array of pixels for each x and y value, prefilled with rgba(0,0,0,1.0)
        var pixelArray = [PixelData](repeating: PixelData(a: 255, r:0, g: 0, b: 0), count: width * height)
        
        //Iterate through the map and get the value for the point
        for x in 0 ..< width {
            
            for y in 0..<height {
                
                var val = matrix[x][y]
                
                //In the case that a number outside of 0-1 got through, get rid of it now
                if val > 1 {
                    val = 1
                }
                
                if val < 0 {
                    val = 0
                }
                
                //This is a one dimensional array so we index it slightly differently
                let index = y * width + x
                
                //We get a value between 0 and 255
                let u_I = UInt8(val * 255)
                
                //This then turns our value into a colour from black to yellow (colour is merely preference)
                pixelArray[index].r = u_I
                pixelArray[index].g = u_I
                pixelArray[index].b = 0
            }
        }
        
        //We create the image, print the time taken to render, and return it
        let outputImage = imageFromARGB32Bitmap(pixels: pixelArray, width: width, height: height)
        
        print("Rendered in: " + String(format: "%.4f", CFAbsoluteTimeGetCurrent() - startTime));
        
        return outputImage
        
    }
    
    
    public func generateLandImage(size:CGSize, matrix:[[CGFloat]]) -> UIImage {
        
        //This is near identical to the function above and the code should really be merged into one function in the future
        let width = Int(size.width)
        let height = Int(size.height)
        
        let startTime = CFAbsoluteTimeGetCurrent();
        
        var pixelArray = [PixelData](repeating: PixelData(a: 255, r:0, g: 0, b: 0), count: width * height)
        
        for i in 0 ..< width {
            for j in 0..<height {
                var val = matrix[i][j]
                if val > 1 {
                    val = 1
                }
                
                if val < 0 {
                    val = 0
                }
                
                let index = j * width + i
                
                //We pick arbitrary values to represent differnent layers, such as in a game and colour them
                if val < 0.4 {               //Water level
                    pixelArray[index].r = 0
                    pixelArray[index].g = 0
                    pixelArray[index].b = 255
                } else if val < 0.55 {        //Sand
                    pixelArray[index].r = 255
                    pixelArray[index].g = 255
                    pixelArray[index].b = 0
                } else if val < 0.75 {        //Grass
                    pixelArray[index].r = 0
                    pixelArray[index].g = 255
                    pixelArray[index].b = 0
                } else {                     //Rock
                    pixelArray[index].r = 40
                    pixelArray[index].g = 40
                    pixelArray[index].b = 40
                }
                
                
            }
        }
        let outputImage = imageFromARGB32Bitmap(pixels: pixelArray, width: width, height: height)
        
        print("Rendered in: " + String(format: "%.4f", CFAbsoluteTimeGetCurrent() - startTime));
        
        return outputImage
        
    }
    
}
