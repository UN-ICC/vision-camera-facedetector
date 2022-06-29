//
//  ImageQualityService.swift
//  vision-camera-facedetector
//
//
//  Created by Andrés Guerrero on 17/05/2022.
//  Copyright © 2022 UNICC. All rights reserved.
//

import Foundation


public struct LuminanceStats {
    var scene: Double
    var splitLightingDifference: Double
}

public class ImageQualityService: NSObject {
    
    private var buffer: CMSampleBuffer
    
    
    init(buffer:CMSampleBuffer) {
        self.buffer = buffer
    }
    
    
    public func getBrightness() -> Double {
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: self.buffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        let brightnessValue : Double = exifData?[kCGImagePropertyExifBrightnessValue as String] as! Double
        return brightnessValue
    }
    
    func getLuminanceStats(bounds: FaceBounds, imageWidth: Int) -> LuminanceStats {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self.buffer) else {
            return LuminanceStats(scene: 1.0, splitLightingDifference: 0.0)
        }
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
        let image = UIImage(cgImage: cgImage)
        
        let imagePixels = Int(image.size.width*image.size.height*4)
        var p = 0
        let provider = cgImage.dataProvider
        let providerData = provider!.data
        let data = CFDataGetBytePtr(providerData)
        
        let midHorizontal = (bounds.right - bounds.left) / 2 + bounds.left
        
        var luminanceScene = 0.0, luminanceL = 0.0, luminanceR = 0.0
        
        var index = 1
        var left = 0, right = 0, scene = 0
        
        
        while p < imagePixels {
            
            let r = CGFloat(data![p]) / 255.0
            let g = CGFloat(data![p + 1]) / 255.0
            let b = CGFloat(data![p + 2]) / 255.0
            let y = index % imageWidth
            let x = index / imageWidth
            
            if (bounds.left <= x && x < midHorizontal && bounds.top <= y && y < bounds.bottom) {
                luminanceL += r*0.299 + g*0.587 + b*0.114
                left += 1
            } else if (midHorizontal <= x && x < bounds.right && bounds.top <= y && y < bounds.bottom) {
                luminanceR += r*0.299 + g*0.587 + b*0.114
                right += 1
            } else {
                luminanceScene += r*0.299 + g*0.587 + b*0.114
                scene += 1
            }
            
            p = p + 4
            index = index + 1
        }
        
        
        return LuminanceStats(scene: luminanceScene/Double(scene),
                              splitLightingDifference: abs((luminanceR / Double(right)) - (luminanceL / Double(left))))
    }
    
    public func getLuminance() -> Double {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(self.buffer) else {
            return 1.0
        }
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
        let image = UIImage(cgImage: cgImage)
        
        let imagePixels = Int(image.size.width*image.size.height*4)
        var p = 0
        let provider = cgImage.dataProvider
        let providerData = provider!.data
        let data = CFDataGetBytePtr(providerData)
        var luminance = 0.0
        while p < imagePixels {
            let r = CGFloat(data![p]) / 255.0
            let g = CGFloat(data![p + 1]) / 255.0
            let b = CGFloat(data![p + 2]) / 255.0
            luminance += r*0.299 + g*0.587 + b*0.114;
            p = p + 4
        }
        
        luminance /= image.size.width*image.size.height;
        return luminance
    }
}
