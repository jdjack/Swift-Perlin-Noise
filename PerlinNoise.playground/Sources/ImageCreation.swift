import UIKit


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
