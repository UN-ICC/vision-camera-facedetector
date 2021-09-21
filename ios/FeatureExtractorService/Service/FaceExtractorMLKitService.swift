//
//  FaceExtractorMLKitService.swift
//  CertificateofEntitlement
//
//  Created by Pablo Romeu on 20/1/21.
//  Copyright © 2021 UNICC. All rights reserved.
//

import MLKitFaceDetection
import MLKitVision
import UIKit

extension Face: Feature{
  var trackingIDValue: Int {
    guard self.hasTrackingID else {
      return -1
    }
    return self.trackingID
  }
  
  var bounds: CGRect {
    return self.frame
  }
  
  var hasSmile: Bool {
    return self.hasSmilingProbability && self.smilingProbability > 0.5
  }
  
  var smileConfidence: Float{
    return Float(self.smilingProbability)
  }
}


class FaceExtractorMLKitService: NSObject,FeatureExtractorServiceProtocol {
  
  
  fileprivate lazy var faceDetector = FaceDetector.faceDetector(options: options)
  
  private var options:FaceDetectorOptions = {
    let theOptions = FaceDetectorOptions()
    theOptions.performanceMode = .accurate
    theOptions.contourMode = .none
    theOptions.landmarkMode = .none
    theOptions.classificationMode = .all
    theOptions.isTrackingEnabled = true
    return theOptions
  }()
  
  private var accuracy:String
  private var cropSize:CGFloat
  fileprivate lazy var ciContext = CIContext()
  
  init(accuracy:String, cropSize:CGFloat) {
    self.accuracy = accuracy
    self.cropSize = cropSize
  }
  
  func extractFace(_ img: UIImage) -> (face: UIImage, features: Feature)? {
    defer {
      ciContext.clearCaches()
    }
    
    
    
    do {
      guard let jpg = img.jpegData(compressionQuality: 1.0),
            let imgForDetection = UIImage(data: jpg)
      else {
        return nil
      }
      let visionImage = VisionImage(image: imgForDetection)
      let featuresArray = try faceDetector.results(in: visionImage)
      guard let feature = featuresArray.first,
            feature.hasSmilingProbability,
            let ciImage = CIImage(image: imgForDetection)
      else {
        return nil
      }
      
      let reducedCIImage = ciImage
        .cropped(to: feature.frame)
      
      guard let cgImage = ciContext.createCGImage(reducedCIImage, from: reducedCIImage.extent) else { return nil }
      let newImage = UIImage(cgImage: cgImage)
      
      UIGraphicsBeginImageContextWithOptions(CGSize(width: cropSize, height: cropSize), false, 1.0);
      newImage.draw(in: CGRect(x: 0, y: 0, width: cropSize, height: cropSize))
      guard let resizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
      UIGraphicsEndImageContext()
      
      return (resizeImage,feature)
    }
    catch let error {
      return nil
    }
  }
}
