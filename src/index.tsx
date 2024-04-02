import { VisionCameraProxy, type Frame } from 'react-native-vision-camera'

const plugin = VisionCameraProxy.initFrameProcessorPlugin('faceDetector')

export function faceDetector(frame: Frame): any {
  'worklet';
  // @ts-ignore
  if (plugin == undefined) throw new Error('Failed to load Frame Processor Plugin "faceDetector"!')

  return plugin.call(frame)
}
