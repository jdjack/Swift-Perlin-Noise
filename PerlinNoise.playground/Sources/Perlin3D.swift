import Foundation

import UIKit

public class Perlin3D: NSObject {
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
    
    func grad(hash:Int, x:CGFloat, y:CGFloat, z:CGFloat) -> CGFloat {
        
        //This takes a hash (a number from 0 - 11) generated from the random permutations and returns a random
        //operation for the node to offset
        
        switch hash & 11 {
        case 0:
            return x + y
        case 1:
            return -x + y
        case 2:
            return x - y
        case 3:
            return -x - y
        case 4:
            return x + z
        case 5:
            return -x + z
        case 6:
            return x - z
        case 7:
            return -x - z
        case 8:
            return y + z
        case 9:
            return -y + z
        case 10:
            return y - z
        case 11:
            return -y - z
        default:
            print("ERROR")
            return 0
        }
        
        
    }
    
    func fastfloor(x:CGFloat) -> Int {
        return x > 0 ? Int(x) : Int(x-1)
    }
    
    public func noise(x:CGFloat, y:CGFloat, z:CGFloat) -> CGFloat {
        
        //Find the unit grid cell containing the point
        var xi = fastfloor(x: x)
        var yi = fastfloor(x: y)
        var zi = fastfloor(x: z)
        
        //This is the other bound of the unit square
        let xf:CGFloat = x - CGFloat(xi)
        let yf:CGFloat = y - CGFloat(yi)
        let zf:CGFloat = z - CGFloat(zi)
        
        //Wrap the ints around 255
        xi = xi & 255
        yi = yi & 255
        zi = zi & 255
        
        //These are offset values for interpolation
        let u = fade(t: xf)
        let v = fade(t: yf)
        let w = fade(t: zf)
        
        //These are the 8 possible permutations so we get the perm value for each
        let aaa = permutation[permutation[permutation[xi] + yi] + zi]
        let aab = permutation[permutation[permutation[xi] + yi] + zi + 1]
        let aba = permutation[permutation[permutation[xi] + yi + 1] + zi]
        let abb = permutation[permutation[permutation[xi] + yi + 1] + zi + 1]
        let baa = permutation[permutation[permutation[xi + 1] + yi] + zi]
        let bab = permutation[permutation[permutation[xi + 1] + yi] + zi]
        let bba = permutation[permutation[permutation[xi + 1] + yi + 1] + zi]
        let bbb = permutation[permutation[permutation[xi + 1] + yi + 1] + zi + 1]
        
        
        //We pair up the permutations, and then interpolate the noise contributions
        
        let naa = lerp(a: grad(hash: aaa, x: xf, y: yf, z: zf), b: grad(hash: baa, x: xf, y: yf, z: zf), x: u)
        let nab = lerp(a: grad(hash: aab, x: xf, y: yf, z: zf), b: grad(hash: bab, x: xf, y: yf, z: zf), x: u)
        let nba = lerp(a: grad(hash: aba, x: xf, y: yf, z: zf), b: grad(hash: bba, x: xf, y: yf, z: zf), x: u)
        let nbb = lerp(a: grad(hash: abb, x: xf, y: yf, z: zf), b: grad(hash: bbb, x: xf, y: yf, z: zf), x: u)
        
        let na = lerp(a: naa, b: nba, x: v)
        let nb = lerp(a: nab, b: nbb, x: v)
        
        let nxyz = lerp(a: na, b: nb, x: w)
        
        //We return the value + 1 / 2 to remove any negatives.
        return (nxyz + 1) / 2
    }
    
    
    public func octaveNoise(x:CGFloat, y:CGFloat, z:CGFloat, octaves:Int, persistence:CGFloat) -> CGFloat {
        
        //This takes several perlin readings (n octaves) and merges them into one map
        var total:CGFloat = 0
        var frequency: CGFloat = 1
        var amplitude: CGFloat = 1
        var maxValue: CGFloat = 0
        
        //We sum the total and divide by the max at the end to normalise
        for _ in 0..<octaves {
            total += noise(x: x * frequency, y: y * frequency, z: z * frequency) * amplitude
            
            maxValue += amplitude
            
            //This is taken from recomendations on values
            amplitude *= persistence
            frequency *= 2
        }
        
        //print(max)
        
        return total/maxValue
    }
    
    
    public func perlinMatrix(width:Int, height: Int, length: Int) -> [[[CGFloat]]] {
        
        var map:[[[CGFloat]]] = []
        
        //We loop through the x and y values and scale by 50. This is an arbritatry value to scale the map
        //You can play with this
        for x in (0...width) {
            
            var row1:[[CGFloat]] = []
            
            for y in (0...height) {
                
                var row2:[CGFloat] = []
                
                for z in (0...length) {
                    
                    let cx:CGFloat = CGFloat(x)/50
                    let cy:CGFloat = CGFloat(y)/50
                    let cz:CGFloat = CGFloat(z)/50
                    
                    let p = noise(x: cx, y: cy, z: cz)
                    
                    row2.append(p)
                }
                
                row1.append(row2)
            }
            
            //We store the map in a matrix for fast access
            map.append(row1)
        }
        
        return map
        
        
    }
    
    
    public func octaveMatrix(width:Int, height: Int, length: Int, octaves:Int, persistance:CGFloat) -> [[[CGFloat]]] {
        
        var map:[[[CGFloat]]] = []
        
        //We loop through the x and y values and scale by 50. This is an arbritatry value to scale the map
        //You can play with this
        for x in (0...width) {
            
            var row1:[[CGFloat]] = []
            
            for y in (0...height) {
                
                var row2:[CGFloat] = []
                
                for z in (0...length) {
                    
                    let cx:CGFloat = CGFloat(x)/50
                    let cy:CGFloat = CGFloat(y)/50
                    let cz:CGFloat = CGFloat(z)/50
                    
                    //We decide to use 8 octaves and 0.25 to generate our map. You can change these too
                    let p = octaveNoise(x: cx, y: cy, z: cz, octaves: octaves, persistence: persistance)
                    
                    row2.append(p)
                }
                
                row1.append(row2)
            }
            map.append(row1)
        }
        
        return map
        
        
    }
}
