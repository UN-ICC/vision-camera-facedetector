package com.visioncamerafacedetector.services

import android.graphics.Rect
import android.util.Log
import androidx.camera.core.ImageProxy
import java.nio.ByteBuffer
import kotlin.math.abs


data class LuminanceStats(val scene: Double, val splitLightingDifference:Double)


class ImageQualityService(buffer: ImageProxy) {

  val imageBuffer: ImageProxy = buffer

  private fun ByteBuffer.toByteArray(): ByteArray {
    rewind()
    val data = ByteArray(remaining())
    get(data)
    return data
  }

  fun getLuminance(): Double {
    // Since format in ImageAnalysis is YUV, image.planes[0] contains the Y (luminance) plane
    val buffer = imageBuffer.planes[0].buffer
    // Extract image data from callback object
    val data = buffer.toByteArray()
    // Convert the data into an array of pixel values
    val pixels = data.map { it.toInt() and 0xFF }
    // Compute average luminance for the image

    return pixels.average() / 255
  }

  fun getLuminanceStats(faceBounds:Rect, imageWidth:Int, rotationDegrees: Int): LuminanceStats {

    // Since format in ImageAnalysis is YUV, image.planes[0] contains the Y (luminance) plane
    val buffer = imageBuffer.planes[0].buffer
    // Extract image data from callback object
    val data = buffer.toByteArray()
    // Compute average luminance for the image

    val midHorizontal = (faceBounds.right - faceBounds.left) / 2 + faceBounds.left
    val midVertical = (faceBounds.bottom - faceBounds.top) / 2 + faceBounds.top
    var luminanceScene = 0.0
    var luminanceR = 0.0
    var luminanceL = 0.0

    var scene = 0
    var left = 0
    var right = 0
    data.forEachIndexed { index, byte ->
      val y = index % imageWidth
      val x = index / imageWidth

      if (faceBounds.left <= x && x < midHorizontal && faceBounds.top <= y && y < faceBounds.bottom) {
        luminanceL += (byte.toInt() and 0xFF).toDouble() / 255.0
        left += 1
      } else if (midHorizontal <= x && x < faceBounds.right && faceBounds.top <= y && y < faceBounds.bottom) {
        luminanceR += (byte.toInt() and 0xFF).toDouble() / 255.0
        right += 1
      } else if (midVertical >= y && rotationDegrees == 90){
        // Monitor only top of the scene
        luminanceScene += (byte.toInt() and 0xFF).toDouble()  / 255.0
        scene += 1
      } else if (midVertical < y && rotationDegrees == 270){
        // Monitor only top of the scene
      luminanceScene += (byte.toInt() and 0xFF).toDouble()  / 255.0
      scene += 1
      }
    }

    return LuminanceStats(luminanceScene/scene, abs((luminanceR / right) - (luminanceL / left)))
  }
}
