//
//  FeatureExtractorServiceProtocol.swift
//  CertificateofEntitlement
//
//  Created by Pablo Romeu on 17/06/2020.
//  Copyright © 2020 UNICC. All rights reserved.
//

import UIKit

protocol Feature{
  var bounds: CGRect { get }
  var hasTrackingID: Bool { get }
  var trackingIDValue: Int { get }
  var hasSmile: Bool { get }
  var smileConfidence: Float { get }
  var eyeRight: Float { get }
  var eyeLeft: Float { get }
}

extension CIFaceFeature: Feature {
  var trackingIDValue: Int {
    return Int(self.trackingID)
  }
  var smileConfidence: Float{
    return self.hasSmile ? 1.0 : 0.0
  }
  var eyeRight: Float{
    return self.rightEyeClosed ? 1.0 : 0.0
  }
  var eyeLeft: Float{
    return self.leftEyeClosed ? 1.0 : 0.0
  }
}

protocol FeatureExtractorServiceProtocol {
  func extractFace(_ img: UIImage) -> (face: [UIImage], features: [Feature])?
}

enum FeatureExtractorServiceType:Int {
  case Native
  case NativeFullImage
  case MLKit
}
