
import AVKit
import Vision


struct FaceBounds {
  var top: Int
  var left: Int
  var right: Int
  var bottom: Int
}

@objc(FaceDetectorFrameProcessorPlugin)
public class FaceDetectorFrameProcessorPlugin: NSObject, FrameProcessorPluginBase {
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
      guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
          return nil
      }
      let ciimage = CIImage(cvPixelBuffer: imageBuffer)
      let context = CIContext(options: nil)
      let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
      let image = UIImage(cgImage: cgImage)
      

      let faceExtractor = FeatureExtractorServiceFactory.serviceWith(type: FeatureExtractorServiceType.MLKit,cropSize: CGFloat(160))


      let extractedData =  faceExtractor.extractFace(image)
      let imageQService = ImageQualityService(buffer: frame.buffer)

      
      guard
        let data = extractedData
      else{
        return []
      }
      
      var results:[[String:Any]] = []
      
      for feature in data.features {
        
        var result =  [String:Any]()
        let faceBounds = FaceBounds(top: Int(feature.bounds.minY ?? 0),
                                    left: Int(feature.bounds.minX ?? 0),
                                    right: Int(feature.bounds.maxX ?? 0),
                                    bottom: Int(feature.bounds.maxY ?? 0)
                                    
        )
        
        let luminanceStats = imageQService.getLuminanceStats(bounds: faceBounds, imageWidth: image.cgImage!.width)
        result.updateValue(Bool(feature.hasSmile ?? false), forKey: "hasSmile")
        result.updateValue([Int(feature.bounds.minX ?? 0),
                            Int(feature.bounds.minY ?? 0),
                            Int(feature.bounds.maxX ?? 0),
                            Int(feature.bounds.maxY ?? 0)], forKey: "bounds")
        result.updateValue(Int(CVPixelBufferGetHeight(imageBuffer)), forKey: "height")
        result.updateValue(Int(CVPixelBufferGetWidth(imageBuffer)), forKey: "width")
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
