import Vision
import AVFoundation
import MLKitVision
import MLKitTextRecognition

@objc(FaceDetectorFrameProcessorPlugin)
public class FaceDetectorFrameProcessorPlugin: NSObject, FrameProcessorPluginBase {

    private static func currentUIOrientation() -> UIDeviceOrientation {
      let deviceOrientation = { () -> UIDeviceOrientation in
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
          return .landscapeRight
        case .landscapeRight:
          return .landscapeLeft
        case .portraitUpsideDown:
          return .portraitUpsideDown
        case .portrait, .unknown:
          return .portrait
        @unknown default:
          fatalError()
        }
      }
      guard Thread.isMainThread else {
        var currentOrientation: UIDeviceOrientation = .portrait
        DispatchQueue.main.sync {
          currentOrientation = deviceOrientation()
        }
        return currentOrientation
      }
      return deviceOrientation()
    }


    private static func imageOrientation(
      fromDevicePosition devicePosition: AVCaptureDevice.Position = .back
    ) -> UIImage.Orientation {
      var deviceOrientation = UIDevice.current.orientation
      if deviceOrientation == .faceDown || deviceOrientation == .faceUp
        || deviceOrientation
          == .unknown
      {
        deviceOrientation = currentUIOrientation()
      }
      switch deviceOrientation {
      case .portrait:
        return devicePosition == .front ? .leftMirrored : .right
      case .landscapeLeft:
        return devicePosition == .front ? .downMirrored : .up
      case .portraitUpsideDown:
        return devicePosition == .front ? .rightMirrored : .left
      case .landscapeRight:
        return devicePosition == .front ? .upMirrored : .down
      case .faceDown, .faceUp, .unknown:
        return .up
      @unknown default:
        fatalError()
      }
    }


  private static func recognizeText(in image: VisionImage) -> (Text?) {
    var recognizedText: Text
    var options: CommonTextRecognizerOptions
    options = TextRecognizerOptions.init()
    do {
      recognizedText = try TextRecognizer.textRecognizer(options:options)
        .results(in: image)
    } catch let error {
      print("Failed to recognize text with error: \(error.localizedDescription).")
      return nil
    }
    return recognizedText
  }


  @objc
  public static func callback(_ frame: Frame!, withArgs _: [Any]!) -> Any! {

    guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
        return nil
    }

    // Convert buffer to UIImage
    let ciimage = CIImage(cvPixelBuffer: imageBuffer)
    let context = CIContext(options: nil)
    let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
    let image = UIImage(cgImage: cgImage)
    let visionImage = VisionImage(image:image)



    guard let recognizedText = recognizeText(in: visionImage) else {
        return []
    }

    var result = [Any]()
    for block in recognizedText.blocks {
        for line in block.lines {
        result.append(
            [
                "text": line.text,
                "bounds": [Int(line.frame.minX),Int(line.frame.minY),Int(line.frame.maxX),Int(line.frame.maxY)],
                "height": Int(CVPixelBufferGetHeight(imageBuffer)),
                "width": Int(CVPixelBufferGetWidth(imageBuffer))
            ]
        )
    	}
    }

    return result
  }
}
