
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
          "trackingId": features?.trackingIDValue as Any
        ] )
      }
      return result
    }
}
