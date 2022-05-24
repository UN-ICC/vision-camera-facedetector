package com.visioncamerafacedetector.services

import androidx.camera.core.ImageProxy
import java.nio.ByteBuffer

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
}
