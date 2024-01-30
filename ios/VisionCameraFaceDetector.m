#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/Frame.h>
#import "VisionCameraFaceDetector-Swift.h" // <--- replace "YOUR_XCODE_PROJECT_NAME" with the actual value of your xcode project name


//VISION_EXPORT_SWIFT_FRAME_PROCESSOR(FaceDetectorFrameProcessorPlugin, faceDetector)


@interface FaceDetectorFrameProcessorPlugin (FrameProcessorPluginLoader)
@end

@implementation FaceDetectorFrameProcessorPlugin (FrameProcessorPluginLoader)

+ (void)load
{
  [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"faceDetector"
                                        withInitializer:^FrameProcessorPlugin* (NSDictionary* options) {
    return [[FaceDetectorFrameProcessorPlugin alloc] init];
  }];
}

@end
