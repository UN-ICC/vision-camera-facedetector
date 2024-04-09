#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import "VisionCameraFaceDetector-Swift.h" // <--- replace "YOUR_XCODE_PROJECT_NAME" with the actual value of your xcode project name


VISION_EXPORT_SWIFT_FRAME_PROCESSOR(FaceDetectorFrameProcessorPlugin, faceDetector)



// Dont ask me why, but Xcode is ignoring the macro above if we dont declare anything else in this file
@interface FaceDetectorFrameProcessorPlugin (mock)
- (id) mock;
@end

@implementation FaceDetectorFrameProcessorPlugin (mock)
- (id) mock {}
@end
