import AVKit
import Vision

@objc(FaceDetectorFrameProcessorPlugin)
 class FaceDetectorFrameProcessorPlugin: NSObject, FrameProcessorPluginBase {
    @objc
 static func callback(_ frame: Frame!, withArgs args: [Any]!) -> Any! {
     return FaceDetectorService.detectFace(frame, withArgs: args)
    }
}
