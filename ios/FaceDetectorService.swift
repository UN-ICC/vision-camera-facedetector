//
//  VisionCameraFaceDetectorService.swift
//  vision-camera-facedetector
//
//  Created by Pablo Romeu on 28/6/22.
//

import Foundation
import AVKit
import Vision


public struct FaceBounds {
    var top: Int
    var left: Int
    var right: Int
    var bottom: Int
}

public struct ImageFaceFeatures{
    public let width: Int
    public let height: Int
    public let feature:Feature
    public let luminance:LuminanceStats
}

public class FaceDetectorService: NSObject {
    
    public static func detectFeatures(_ frame: Frame!, withArgs args: [Any]!) -> [ImageFaceFeatures]? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
            return nil
        }
      
        var orientation: CGImagePropertyOrientation = .up
      
        if args[1] as? String == "landscapeLeft" {
          orientation = .down
        }
        
        let ciimage = CIImage(cvPixelBuffer: imageBuffer).oriented(orientation)
        
      
        let context = CIContext(options: nil)

      
        let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
        let image = UIImage(cgImage: cgImage)
        
        

      
        let faceExtractor = FeatureExtractorServiceFactory.serviceWith(type: FeatureExtractorServiceType.MLKit,cropSize: CGFloat(160))
        
        
        let extractedData =  faceExtractor.extractFace(image)
        let imageQService = ImageQualityService(buffer: frame.buffer, orientation: orientation)
        
        
        guard
            let data = extractedData
        else{
            return []
        }
        
        var results:[ImageFaceFeatures] = []
        
        for feature in data.features {
            
            var result =  [String:Any]()
            let faceBounds = FaceBounds(top: Int(feature.bounds.minY ?? 0),
                                        left: Int(feature.bounds.minX ?? 0),
                                        right: Int(feature.bounds.maxX ?? 0),
                                        bottom: Int(feature.bounds.maxY ?? 0)
                                        
            )
            
            let luminanceStats = imageQService.getLuminanceStats(bounds: faceBounds, imageWidth: image.cgImage!.width)
            
            let height = Int(image.cgImage!.height)
            let width = Int(image.cgImage!.width)
            
            results.append(ImageFaceFeatures(
                width: width,
                height: height,
                feature: feature,
                luminance: luminanceStats))
        }
        
        return results
    }
    
    public static func detectFace(_ frame: Frame!, withArgs args: [Any]!) -> [[String:Any]]? {
        
        guard let imageFeatures = FaceDetectorService.detectFeatures(frame, withArgs: args) else {
            return nil
        }
        
        var results: [[String:Any]] = []
        
        for imageFeature in imageFeatures {
            
            var result =  [String:Any]()
            let feature = imageFeature.feature
            let luminanceStats = imageFeature.luminance
            
            result.updateValue(Bool(feature.hasSmile ?? false), forKey: "hasSmile")
            result.updateValue([Int(feature.bounds.minX ?? 0),
                                Int(feature.bounds.minY ?? 0),
                                Int(feature.bounds.maxX ?? 0),
                                Int(feature.bounds.maxY ?? 0)], forKey: "bounds")
            result.updateValue(imageFeature.height, forKey: "height")
            result.updateValue(imageFeature.width, forKey: "width")
            result.updateValue(Float(feature.eyeRight ?? 0.0), forKey: "eyeRight")
            result.updateValue(Float(feature.eyeLeft ?? 0.0), forKey: "eyeLeft")
            result.updateValue(feature.trackingIDValue as Any, forKey: "trackingId")
            result.updateValue(luminanceStats.scene, forKey: "luminance")
            result.updateValue(luminanceStats.splitLightingDifference, forKey: "splitLightingDifference")
            results.append(result)
        }
        
        return results
    }
}
