import { VisionCameraProxy, type Frame } from 'react-native-vision-camera'

const plugin = VisionCameraProxy.initFrameProcessorPlugin('faceDetector')

export interface FaceDetectorConfig{
  camera?: string;
  orientation?: string;
}

export function faceDetector(frame: Frame, config?: FaceDetectorConfig): any {
  'worklet';
  // @ts-ignore
  if (plugin == undefined) throw new Error('Failed to load Frame Processor Plugin "faceDetector"!')
  if (config) {
    let record: Record<string, any> = {};
    record["camera"] = config.camera;
    record["orientation"] = config.orientation;
    return plugin.call(frame, record)
  }
  else {
    return plugin.call(frame)
  }


}
