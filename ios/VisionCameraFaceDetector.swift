
import AVKit
import Vision

@objc(FaceDetectorFrameProcessorPlugin)
public class FaceDetectorFrameProcessorPlugin: NSObject, FrameProcessorPluginBase {
    @objc
    public static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
      guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
          return nil
      }

      // Convert buffer to UIImage
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
