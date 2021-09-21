/* eslint-disable no-undef */
import type { Frame } from 'react-native-vision-camera';

/**
 * Scans OCR.
 */

export function faceDetector(frame: Frame): any {
  'worklet';
  // @ts-ignore
  return __faceDetector(frame);
}
