//
//  NaticeFeatureExtractorService.swift
//  CertificateofEntitlement
//
//  Created by Pablo Romeu on 17/06/2020.
//  Copyright © 2020 UNICC. All rights reserved.
//

import UIKit

class NativeFeatureExtractorService: FeatureExtractorServiceProtocol {
  
  private var accuracy:String
  private var cropSize:CGFloat
  fileprivate lazy var faceDetector = CIDetector(ofType: CIDetectorTypeFace,
                                                 context: nil,
                                                 options: [
                                                  CIDetectorAccuracy: accuracy,
                                                  CIDetectorTracking: false
                                                 ])!
  fileprivate lazy var ciContext = CIContext()
  init(accuracy:String = CIDetectorAccuracyLow, cropSize:CGFloat) {
    self.accuracy = accuracy
    self.cropSize = cropSize
  }
  
  func extractFace(_ img: UIImage) -> (face: [UIImage], features: [Feature])? {
    defer {
      ciContext.clearCaches()
    }
    guard let ciImage = CIImage(image: img) else {
      return nil
    }
    //Detects faces base on your `ciImage`
    let featuresArray = faceDetector.features(in: ciImage, options: [
      CIDetectorSmile: true
    ]).compactMap({ $0 as? CIFaceFeature })
    
    
    var features: [Feature] = []
    var resizedImages: [UIImage] = []
    
    for f in featuresArray{
      let feature = f
      
      let reducedCIImage = ciImage
        .cropped(to: feature.bounds)
      
      guard let cgImage = ciContext.createCGImage(reducedCIImage, from: reducedCIImage.extent) else { return nil }
      let newImage = UIImage(cgImage: cgImage)
      
      UIGraphicsBeginImageContextWithOptions(CGSize(width: cropSize, height: cropSize), false, 0.0);
      newImage.draw(in: CGRect(x: 0, y: 0, width: cropSize, height: cropSize))
      guard let resizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
      UIGraphicsEndImageContext()
      resizedImages.append(resizeImage)
      features.append(feature)
    }
    
    return (resizedImages,features)
  }
  
}
