//
//  FeatureExtractorServiceFactory.swift
//  CertificateofEntitlement
//
//  Created by Pablo Romeu on 17/06/2020.
//  Copyright © 2020 UNICC. All rights reserved.
//

import UIKit

class FeatureExtractorServiceFactory: NSObject{
  class func serviceWith(type: FeatureExtractorServiceType,
                         accuracy:String = CIDetectorAccuracyLow,
                         cropSize:CGFloat) -> FeatureExtractorServiceProtocol {
    switch type {
    case .Native:
      return NativeFeatureExtractorService(accuracy: accuracy, cropSize: cropSize)
    case .NativeFullImage:
      return NativeFeatureExtractorFullImageService(accuracy: accuracy, cropSize: cropSize)
    case .MLKit:
      return FaceExtractorMLKitService(accuracy: accuracy, cropSize: cropSize)
    }
  }
}
