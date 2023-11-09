package com.visioncamerafacedetector.services

import android.graphics.Rect
import android.util.Log
import androidx.camera.core.ImageProxy
import org.opencv.core.Core
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.Point
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import java.nio.ByteBuffer
import kotlin.math.abs


data class LuminanceStats(val scene: Double, val splitLightingDifference:Double)


class ImageQualityService(buffer: ImageProxy) {

  // Since format in ImageAnalysis is YUV, image.planes[0] contains the Y (luminance) plane
  val luminanceByteArray: ByteArray = imageProxyToByteArray(buffer)
  val rotationDegrees: Int = buffer.imageInfo.rotationDegrees

  private fun imageProxyToByteArray(imageProxy: ImageProxy): ByteArray {
      val yBuffer = imageProxy.planes[0].buffer
      val ySize = yBuffer.remaining()
      val yByteArray = ByteArray(ySize)
      yBuffer.get(yByteArray)
      val matYuv = Mat(imageProxy.height, imageProxy.width, CvType.CV_8UC1)
      matYuv.put(0, 0, yByteArray)
        if (imageProxy.imageInfo.rotationDegrees==90) {
          val matYuv = Mat(imageProxy.height, imageProxy.width, CvType.CV_8UC1)
          matYuv.put(0, 0, yByteArray)
          val rotatedMat = Mat(matYuv.width(), matYuv.height(),CvType.CV_8UC1)
          Core.rotate(matYuv,rotatedMat, Core.ROTATE_90_COUNTERCLOCKWISE)
          val yRotatedByteArray = ByteArray(ySize)
          rotatedMat.get(0, 0, yRotatedByteArray)
        return yRotatedByteArray
      }
      return yByteArray
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
