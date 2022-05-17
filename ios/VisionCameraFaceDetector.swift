
import AVKit
import Vision

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
      
      let imageQService = ImageQualityService(buffer: frame.buffer)
      let luminance = imageQService.getBrightness()

      let faceExtractor = FeatureExtractorServiceFactory.serviceWith(type: FeatureExtractorServiceType.MLKit,cropSize: CGFloat(160))


      let extractedData =  faceExtractor.extractFace(image)
      let features = extractedData?.features


  
      var result =  [String:Any]()

      if ((features) != nil) {
        result.updateValue(Bool(features?.hasSmile ?? false), forKey: "hasSmile")
        result.updateValue([Int(features?.bounds.minX ?? 0),
                            Int(features?.bounds.minY ?? 0),
                            Int(features?.bounds.maxX ?? 0),
                            Int(features?.bounds.maxY ?? 0)], forKey: "bounds")
        result.updateValue(Int(CVPixelBufferGetHeight(imageBuffer)), forKey: "height")
        result.updateValue(Int(CVPixelBufferGetWidth(imageBuffer)), forKey: "width")
        result.updateValue(Float(features?.eyeRight ?? 0.0), forKey: "eyeRight")
        result.updateValue(Float(features?.eyeLeft ?? 0.0), forKey: "eyeLeft")
        result.updateValue(features?.trackingIDValue as Any, forKey: "trackingId")
        result.updateValue(luminance, forKey: "luminance")
        
      }
      return [result]
    }
}
