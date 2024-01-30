import VisionCamera

@objc(FaceDetectorFrameProcessorPlugin)
 public class FaceDetectorFrameProcessorPlugin: FrameProcessorPlugin {

    public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable : Any]! = [:]) {
      super.init(proxy: proxy, options: options)
    }

    public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable : Any]?) -> Any {
      return FaceDetectorService.detectFace(frame, withArgs: arguments)
    }
}
