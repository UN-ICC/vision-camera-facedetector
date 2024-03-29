package com.visioncamerafacedetector

import android.graphics.Rect
import android.media.Image
import android.util.Log
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.face.Face
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import com.mrousavy.camera.frameprocessor.Frame
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin
import com.mrousavy.camera.frameprocessor.VisionCameraProxy
import com.visioncamerafacedetector.services.ImageQualityService
import com.visioncamerafacedetector.services.LuminanceStats
import kotlin.random.Random


class VisionCameraFaceDetectorPlugin(proxy: VisionCameraProxy, options: Map<String, Any>?): FrameProcessorPlugin() {
    init {
        Log.d("VisionCameraFaceDetecto", "ExampleKotlinFrameProcessorPlugin initialized with options: " + options?.toString())
    }

  fun flipHorizontal(rectangle: Rect, imageWidth: Int): Rect {
    val flippedRectangle = Rect()
    flippedRectangle.left = imageWidth - rectangle.right // New x1
    flippedRectangle.right = imageWidth - rectangle.left // New x2
    flippedRectangle.top = rectangle.top // New y1
    flippedRectangle.bottom = rectangle.bottom // New y2
    return flippedRectangle
  }

  override fun callback(frame: Frame, arguments: Map<String, Any>?): Any {
    val mediaImage: Image? = frame.image
    val options = FaceDetectorOptions.Builder()
      .setContourMode(FaceDetectorOptions.CONTOUR_MODE_NONE)
      .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
      .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_NONE)
      .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
      .enableTracking()
      .build()

    var rotated: Boolean = false
    var flipped: Boolean = false

    val rotationDegrees: Int = frame.orientation.toDegrees()

    if (arguments != null) {
      for (key in arguments.keys) {
        Log.d("VisionCameraFaceDetecto", "key = $key");
      }
      if (arguments.containsKey("isFront")) {
        flipped = arguments["isFront"] as Boolean
      }
      if (arguments.containsKey("rotateImage")) {
        rotated = arguments["rotateImage"] as Boolean
        Log.d("VisionCameraFaceDetecto","rot: "+rotated);
      }
    }

    val array = arrayListOf<Any>()

    if (mediaImage != null) {
      val imageService = ImageQualityService(mediaImage)
      val detector = FaceDetection.getClient(options)
      val task: Task<List<Face>> = detector.process(mediaImage, rotationDegrees)
      try {
        val faces = Tasks.await(task)

        if (faces.isNotEmpty()) {
          for (face in faces) {

            var f = Rect(face.boundingBox.left, face.boundingBox.top, face.boundingBox.right, face.boundingBox.bottom)

            val luminanceStats: LuminanceStats = imageService.getLuminanceStats(f, mediaImage.width)

            val imageWidth = if (rotated) mediaImage.height else mediaImage.width
            val imageHeight = if (rotated) mediaImage.width else mediaImage.height

            val map = mutableMapOf<String, Any>()
            map["hasSmile"] = face.smilingProbability?.let { it > 0.5 } ?: false
            map["trackingId"] = face.trackingId ?: Random.nextInt(2)
            map["height"] = imageHeight
            map["width"] = imageWidth
            map["eyeRight"] = (face.rightEyeOpenProbability?.toDouble() ?: 0.0)
            map["eyeLeft"] = (face.leftEyeOpenProbability?.toDouble() ?: 0.0)
            map["luminance"] = luminanceStats.scene
            map["splitLightingDifference"] = luminanceStats.splitLightingDifference

            if (flipped && rotated) f = flipHorizontal(f, mediaImage.height)
            if (flipped && !rotated) f = flipHorizontal(f, mediaImage.width)
            val bounds = arrayListOf<Int>()
            bounds.add(f.left)
            bounds.add(f.top)
            bounds.add(f.right)
            bounds.add(f.bottom)
            map["bounds"] = bounds
            array.add(map)
          }
        }
      } catch (e: Exception) {
        e.printStackTrace()
      }
    }
    return array
  }
}
