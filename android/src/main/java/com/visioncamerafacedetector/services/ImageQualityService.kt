package com.visioncamerafacedetector.services

import android.graphics.Bitmap
import android.graphics.Rect
import android.graphics.drawable.BitmapDrawable
import android.media.Image
import java.io.ByteArrayOutputStream
import kotlin.math.abs


data class LuminanceStats(val scene: Double, val splitLightingDifference:Double)


class ImageQualityService(buffer: Image) {

  // Since format in ImageAnalysis is YUV, image.planes[0] contains the Y (luminance) plane
  val luminanceByteArray: ByteArray = imageToByteArray(buffer)

  private fun imageToByteArray(image: Image): ByteArray {
    val nv21: ByteArray
    val yBuffer = image.planes[0].buffer
    val uBuffer = image.planes[1].buffer
    val vBuffer = image.planes[2].buffer
    val ySize = yBuffer.remaining()
    val uSize = uBuffer.remaining()
    val vSize = vBuffer.remaining()
    nv21 = ByteArray(ySize + uSize + vSize)

    //U and V are swapped
    yBuffer[nv21, 0, ySize]
    vBuffer[nv21, ySize, vSize]
    uBuffer[nv21, ySize + vSize, uSize]
    return nv21
  }

  fun getLuminance(): Double {
    // Convert the data into an array of pixel values
    val pixels = luminanceByteArray.map { it.toInt() and 0xFF }
    // Compute average luminance for the image
    return pixels.average() / 255
  }

  fun getLuminanceStats(faceBounds:Rect, imageWidth:Int): LuminanceStats {

    // Compute average luminance for the image

    val midHorizontal = (faceBounds.right - faceBounds.left) / 2 + faceBounds.left
    val midVertical = (faceBounds.bottom - faceBounds.top) / 2 + faceBounds.top
    var luminanceScene = 0.0
    var luminanceR = 0.0
    var luminanceL = 0.0

    var scene = 0
    var left = 0
    var right = 0
    luminanceByteArray.forEachIndexed { index, byte ->
      val y = index % imageWidth
      val x = index / imageWidth

      if (faceBounds.left <= x && x < midHorizontal && faceBounds.top <= y && y < faceBounds.bottom) {
        luminanceL += (byte.toInt() and 0xFF).toDouble() / 255.0
        left += 1
      } else if (midHorizontal <= x && x < faceBounds.right && faceBounds.top <= y && y < faceBounds.bottom) {
        luminanceR += (byte.toInt() and 0xFF).toDouble() / 255.0
        right += 1
      } else {
        luminanceScene += (byte.toInt() and 0xFF).toDouble()  / 255.0
        scene += 1
      }
    }
    return LuminanceStats(luminanceScene/scene, abs((luminanceR / right) - (luminanceL / left)))
  }
}
