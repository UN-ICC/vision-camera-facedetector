package com.visioncamerafacedetector

import android.annotation.SuppressLint
import android.media.Image
import androidx.camera.core.ImageProxy
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin


class VisionCameraFaceDetectorPlugin: FrameProcessorPlugin("faceDetector") {

  override fun callback(frame: ImageProxy, params: Array<Any>): Any? {
    @SuppressLint("UnsafeOptInUsageError")
    val mediaImage: Image? = frame.image
    val options = FaceDetectorOptions.Builder()
      .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
      .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
      .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
      .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
      .enableTracking()
      .build()

    val array = WritableNativeArray()

    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, frame.imageInfo.rotationDegrees)
      val detector = FaceDetection.getClient(options)
      val result = detector.process(image)
        .addOnSuccessListener { faces ->
          // Task completed successfully
          // ...
          if (faces.size != 1){
            for (face in faces) {
              val map = WritableNativeMap()
              map.putBoolean("hasSmile", face.smilingProbability>0.5)
              map.putInt("trackingId", face.trackingId)
              map.putInt("height", if (frame.imageInfo.rotationDegrees == 90) image.width else image.height)
              map.putInt("width", if (frame.imageInfo.rotationDegrees == 90) image.height else image.width)
              val bounds = WritableNativeArray()
              bounds.pushInt(face.boundingBox?.left)
              bounds.pushInt(face.boundingBox?.top)
              bounds.pushInt(face.boundingBox?.right)
              bounds.pushInt(face.boundingBox?.bottom)
              map.putArray("bounds", bounds)
              array.pushMap(map)
            }
          }

        }
        .addOnFailureListener { e ->
          // Task failed with an exception
          // ...
        }

    }
    return array
  }
}
