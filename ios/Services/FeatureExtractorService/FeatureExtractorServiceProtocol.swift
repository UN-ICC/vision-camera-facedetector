//
//  FeatureExtractorServiceProtocol.swift
//  CertificateofEntitlement
//
//  Created by Pablo Romeu on 17/06/2020.
//  Copyright © 2020 UNICC. All rights reserved.
//

import UIKit

public protocol Feature{
    var bounds: CGRect { get }
    var hasTrackingID: Bool { get }
    var trackingIDValue: Int { get }
    var hasSmile: Bool { get }
    var smileConfidence: Float { get }
    var eyeRight: Float { get }
    var eyeLeft: Float { get }
    var angleX: Float { get }
    var angleY: Float { get }
    var angleZ: Float { get }
}

extension CIFaceFeature: Feature {
     public var angleX: Float {
        return Float(0)
     }

    public var angleY: Float {
      return Float(0)
    }

    public var angleZ: Float {
      return Float(0)
    }

    public var trackingIDValue: Int {
        return Int(self.trackingID)
    }
    public var smileConfidence: Float{
        return self.hasSmile ? 1.0 : 0.0
    }
    public var eyeRight: Float{
        return self.rightEyeClosed ? 1.0 : 0.0
    }
    public var eyeLeft: Float{
        return self.leftEyeClosed ? 1.0 : 0.0
    }
}

public protocol FeatureExtractorServiceProtocol {
    func extractFace(_ img: UIImage) -> (face: [UIImage], features: [Feature])?
}

public enum FeatureExtractorServiceType:Int {
    case Native
    case NativeFullImage
    case MLKit
}
