import { VisionCameraProxy, Frame } from 'react-native-vision-camera';

const plugin = VisionCameraProxy.initFrameProcessorPlugin('faceDetector');

/**
 * Scans OCR.
 */

export function faceDetector(frame: Frame): any {
  'worklet';
  // @ts-ignore
  if (plugin == null) throw new Error('Failed to load Frame Processor Plugin "faceDetector"!')

  return plugin.call(frame);
}
