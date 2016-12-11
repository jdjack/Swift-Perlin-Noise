import UIKit

public class Perlin: NSObject {
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
    
    func grad(hash:Int, x:CGFloat, y:CGFloat) -> CGFloat {
        
        //This takes a hash (a number from 0 - 5) generated from the random permutations and returns a random
        //operation for the node to offset
        
        switch hash & 5 {
        case 0:
            return x + y
        case 1:
            return -x + y
        case 2:
            return x - y
        case 3:
            return -x - y
        case 4:
            return y + x
        case 5:
            return y - x
        default:
            print("ERROR")
            return 0
        }
        
        
    }
    
    func perlin(x:CGFloat, y:CGFloat) -> CGFloat {
        
        //We ensure the point is bounded by 255 - This is the one bound of the unit square
        let xi = Int(x) & 255
        let yi = Int(y) & 255
        
        //This is the other bound of the unit square
        let xf:CGFloat = x - floor(x)
        let yf:CGFloat = y - floor(y)
        
        
        //These are offset values for interpolation
        let u = fade(t: xf)
        let v = fade(t: yf)
        
        
        //These are the 4 possible permutations so we get the perm value for each
        let aa = permutation[permutation[xi] + yi]
        let ab = permutation[permutation[xi] + yi + 1]
        let ba = permutation[permutation[xi + 1] + yi]
        let bb = permutation[permutation[xi + 1] + yi + 1]
        
        
        //We pair aa and ba, and ab and bb and lerp the gradient of the two, using the offset values
        //We take 1 off the value which we added one to for the perms
        let x1 = lerp(a: grad(hash: aa, x: xf, y: yf), b: grad(hash: ba, x: xf - 1, y: yf), x: u)
        let x2 = lerp(a: grad(hash: ab, x: xf, y: yf - 1), b: grad(hash: bb, x: xf - 1, y: yf - 1), x: u)
        let y1 = lerp(a: x1, b: x2, x: v)
        
        //We multiply by 2 just to produce a less "Black and White" noise map, and add one and divide by two to try and ensure positive numbers - some do still sneak through
        return ((y1 * 2) + 1) / 2
    }
    
    
    public func octavePerlin(x:CGFloat, y:CGFloat, octaves:Int, persistence:CGFloat) -> CGFloat {
        
        //This takes several perlin readings (n octaves) and merges them into one map
        var total:CGFloat = 0
        var frequency: CGFloat = 1
        var amplitude: CGFloat = 1
        var maxValue: CGFloat = 0
        
        //We sum the total and divide by the max at the end to normalise
        for _ in 0..<octaves {
            total += perlin(x: x * frequency, y: y * frequency) * amplitude
            
            maxValue += amplitude
            
            //This is taken from recomendations on values
            amplitude *= persistence
            frequency *= 2
        }
        
        return total/maxValue
    }

    
    public func octaveMap(width:Int, height: Int) -> [[CGFloat]] {
        var map:[[CGFloat]] = []
        
        //We loop through the x and y values and scale by 50. This is an arbritatry value to scale the map
        //You can play with this
        for x in (0...width) {
            
            var row:[CGFloat] = []
            
            for y in (0...height) {
                let cx:CGFloat = CGFloat(x)/50
                let cy:CGFloat = CGFloat(y)/50
                
                //We decide to use 8 octaves and 0.25 to generate our map. You can change these too
                let p = octavePerlin(x: cx, y: cy, octaves: 8, persistence: 0.25)
                
                row.append(p)
            }
            
            //We store the map in a matrix for fast access
            map.append(row)
        }
        
        return map
        

    }
    
    
    public func generateNoiseImage(size:CGSize) -> UIImage {
        
        
        let width = Int(size.width)
        let height = Int(size.height)
        
        //This times how long it takes to render, useful for testing its limits
        let startTime = CFAbsoluteTimeGetCurrent();
        
        //Create the map with the defined width
        let map = octaveMap(width: width, height: height)
        
        //Create an array of pixels for each x and y value, prefilled with rgba(0,0,0,1.0)
        var pixelArray = [PixelData](repeating: PixelData(a: 255, r:0, g: 0, b: 0), count: width * height)
        
        //Iterate through the map and get the value for the point
        for x in 0 ..< width {
            
            for y in 0..<height {
                
                var val = map[x][y]
                
                //In the case that a number outside of 0-1 got through, get rid of it now
                if val > 1 {
                    val = 1
                }

                if val < 0 {
                    val = 0
                }
                
                //This is a one dimensional array so we index it slightly differently
                let index = x * width + y
                
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
    
    
    public func generateLandImage(size:CGSize) -> UIImage {
        
        //This is near identical to the function above and the code should really be merged into one function in the future
        let width = Int(size.width)
        let height = Int(size.height)
        
        let startTime = CFAbsoluteTimeGetCurrent();
        
        let map = octaveMap(width: width, height: height)
        
        var pixelArray = [PixelData](repeating: PixelData(a: 255, r:0, g: 0, b: 0), count: width * height)
        
        for i in 0 ..< width {
            for j in 0..<height {
                var val = map[i][j]
                if val > 1 {
                    val = 1
                }
                
                if val < 0 {
                    val = 0
                }
                
                let index = i * width + j
                
                //We pick arbitrary values to represent differnent layers, such as in a game and colour them
                if val < 0.3 {               //Water level
                    pixelArray[index].r = 0
                    pixelArray[index].g = 0
                    pixelArray[index].b = 255
                } else if val < 0.5 {        //Sand
                    pixelArray[index].r = 255
                    pixelArray[index].g = 255
                    pixelArray[index].b = 0
                } else if val < 0.7 {        //Grass
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
    
    
    
    //Create a struct to nicely hold the rgba data
    struct PixelData {
        var a:UInt8 = 255
        var r:UInt8
        var g:UInt8
        var b:UInt8
    }
    
    //The below creates and rgb space and creates a bitmap area to store pixel data
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    
    
    func imageFromARGB32Bitmap(pixels:[PixelData], width:Int, height:Int)->UIImage {
        
        //8 bits for r,g,b and a, so 32 bits total
        let bitsPerComponent:Int = 8
        let bitsPerPixel:Int = 32
        
        //We check that there is a pixel for every x and y value
        assert(pixels.count == Int(width * height))
        
        var data = pixels //We copy the pixel data
        
        //We pass our data in so we have a reference to create the image with
        let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size))
        
        //We now create the image with the values that we have defined!
        let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * Int(MemoryLayout<PixelData>.size),
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
        
        //We turn the CGImage into a UIImage
        return UIImage(cgImage: cgim!)
    }

}
