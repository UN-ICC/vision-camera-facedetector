package com.visioncamerafacedetector

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.Rect
import android.media.Image
import android.util.Log
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
import com.visioncamerafacedetector.services.ImageQualityService
import com.visioncamerafacedetector.services.LuminanceStats


class VisionCameraFaceDetectorPlugin: FrameProcessorPlugin("faceDetector") {


  fun flipHorizontal(rectangle: Rect, imageWidth: Int): Rect {
    val flippedRectangle = Rect()
    flippedRectangle.left = imageWidth - rectangle.right // New x1
    flippedRectangle.right = imageWidth - rectangle.left // New x2
    flippedRectangle.top = rectangle.top // New y1
    flippedRectangle.bottom = rectangle.bottom // New y2
    return flippedRectangle
  }

  override fun callback(frame: ImageProxy, params: Array<Any>): Any? {
    @SuppressLint("UnsafeOptInUsageError")

    val camera: String = if (params.size > 0 && params[0] is String) params[0].toString() else "unknown"
    val rotationDegrees: Int = frame.imageInfo.rotationDegrees
    val mediaImage: Image? = frame.image
    val options = FaceDetectorOptions.Builder()
      .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
      .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
      .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
      .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
      .enableTracking()
      .build()

    val imageService = ImageQualityService(frame)

    val rotated: Boolean = (rotationDegrees == 90 || rotationDegrees == 270)
    val flipped: Boolean = (camera=="front")

    val array = WritableNativeArray()

    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, rotationDegrees)
      val detector = FaceDetection.getClient(options)
      var task: Task<List<Face>> = detector.process(image)
      try {
        var faces = Tasks.await(task)

        if (faces.size >= 1) {
          for (face in faces) {

            var f = Rect(face.boundingBox.left, face.boundingBox.top, face.boundingBox.right, face.boundingBox.bottom)

            val luminanceStats:LuminanceStats = imageService.getLuminanceStats(f, image.width, rotationDegrees)

            val imageWidth = if (rotated) image.height else image.width
            val imageHeight = if (rotated) image.width else image.height

            val map = WritableNativeMap()
            map.putBoolean("hasSmile", face.smilingProbability > 0.5)
            map.putInt("trackingId", face.trackingId)
            map.putInt("height", imageHeight)
            map.putInt("width",imageWidth)
            map.putDouble("eyeRight", face.rightEyeOpenProbability.toDouble())
            map.putDouble("eyeLeft", face.leftEyeOpenProbability.toDouble())
            map.putDouble("luminance", luminanceStats.scene)
            map.putDouble("splitLightingDifference", luminanceStats.splitLightingDifference)

            if (flipped && rotated) f = flipHorizontal(f, image.height)
            if (flipped && !rotated) f = flipHorizontal(f, image.width)
            val bounds = WritableNativeArray()
            bounds.pushInt(f.left)
            bounds.pushInt(f.top)
            bounds.pushInt(f.right)
            bounds.pushInt(f.bottom)
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
