/* eslint-disable no-undef */
import type { Frame } from 'react-native-vision-camera';

/**
 * Scans OCR.
 */

export function faceDetectorOCR(frame: Frame): any {
  'worklet';
  // @ts-ignore
  return __faceDetector(frame);
}
