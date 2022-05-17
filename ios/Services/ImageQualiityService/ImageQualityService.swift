//
//  ImageQualityService.swift
//  vision-camera-facedetector
//
//
//  Created by Andrés Guerrero on 17/05/2022.
//  Copyright © 2022 UNICC. All rights reserved.
//

import Foundation


class ImageQualityService: NSObject {
  
  private var buffer: CMSampleBuffer

  
  init(buffer:CMSampleBuffer) {
    self.buffer = buffer
  }
  
  
  func getBrightness() -> Double {
    let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: self.buffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
      let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
      let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
      let brightnessValue : Double = exifData?[kCGImagePropertyExifBrightnessValue as String] as! Double
      return brightnessValue
  }
  
  func getLuminance() -> Double {
    
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
