
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
      
      
      
      var imagePixels = Int(image.size.width*image.size.height*4)
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


      var result:[Any] = []

      if ((features) != nil) {
        result.append([
          "hasSmile": Bool(features?.hasSmile ?? false),
          "bounds": [Int(features?.bounds.minX ?? 0),
                     Int(features?.bounds.minY ?? 0),
                     Int(features?.bounds.maxX ?? 0),
                     Int(features?.bounds.maxY ?? 0)],
          "height": Int(CVPixelBufferGetHeight(imageBuffer)),
          "width": Int(CVPixelBufferGetWidth(imageBuffer)),
          "trackingId": features?.trackingIDValue as Any,
          "luminance": luminance
        ] )
      }
      return result
    }
}

