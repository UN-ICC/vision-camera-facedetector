import * as React from 'react'

import { StyleSheet, View, Text } from 'react-native'

import {
  Camera,
  useCameraDevice,
  useCameraPermission,
  useFrameProcessor,
} from 'react-native-vision-camera'
import { faceDetector } from 'vision-camera-facedetector'

export default function App(): React.ReactNode {
  const { hasPermission, requestPermission } = useCameraPermission()
  const device = useCameraDevice('front')

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet'
    const faces  = faceDetector(frame)
    console.log('Result: ', faces)
  }, [])

  React.useEffect(() => {
    requestPermission().then()
  }, [requestPermission])

  return (
    <View style={styles.container}>
      {hasPermission && device !== undefined ? (
        <Camera
          device={device}
          style={StyleSheet.absoluteFill}
          isActive={true}
          frameProcessor={frameProcessor}
          pixelFormat="yuv"
        />
      ) : (
        <Text>No Camera available.</Text>
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
})
