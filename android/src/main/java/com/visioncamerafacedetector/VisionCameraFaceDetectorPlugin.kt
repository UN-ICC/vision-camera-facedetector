package com.visioncamerafacedetector

import android.annotation.SuppressLint
import android.media.Image
import androidx.camera.core.ImageProxy
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.Face
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

    val rotated: Boolean = (frame.imageInfo.rotationDegrees == 90 || frame.imageInfo.rotationDegrees == 270)

    val array = WritableNativeArray()

    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, frame.imageInfo.rotationDegrees)
      val detector = FaceDetection.getClient(options)
      var task: Task<List<Face>> = detector.process(image)
      try {
        var faces = Tasks.await(task)

        if (faces.size == 1) {
          for (face in faces) {
            val map = WritableNativeMap()
            map.putBoolean("hasSmile", face.smilingProbability > 0.5)
            map.putInt("trackingId", face.trackingId)
            map.putInt("height", if (rotated) image.width else image.height)
            map.putInt("width", if (rotated) image.height else image.width)
            val bounds = WritableNativeArray()
            bounds.pushInt(minOf(face.boundingBox?.left,face.boundingBox?.right))
            bounds.pushInt(minOf(face.boundingBox?.top,face.boundingBox?.bottom))
            bounds.pushInt(maxOf(face.boundingBox?.left,face.boundingBox?.right))
            bounds.pushInt(maxOf(face.boundingBox?.top,face.boundingBox?.bottom))
            map.putArray("bounds", bounds)
            array.pushMap(map)
          }
        }
      } catch (e: Exception) {
        e.printStackTrace()
      }
    }
    return array
  }
}
