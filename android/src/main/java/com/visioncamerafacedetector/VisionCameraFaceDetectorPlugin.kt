import android.R.attr.label
import android.annotation.SuppressLint
import android.graphics.Rect
import android.media.Image
import androidx.camera.core.ImageProxy
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin
import com.mrousavy.camera.utils.pushInt


class VisionCameraOcrPlugin: FrameProcessorPlugin("faceDetector") {

  override fun callback(frame: ImageProxy, params: Array<Any>): Any? {
    @SuppressLint("UnsafeOptInUsageError")
    val mediaImage: Image? = frame.image
    val textRecognizer: TextRecognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    val array = WritableNativeArray()


    if (mediaImage != null) {
      val image = InputImage.fromMediaImage(mediaImage, frame.imageInfo.rotationDegrees)
      var task: Task<Text> = textRecognizer.process(image)
      try {
        var extractedInfo = Tasks.await(task)
        for (block in extractedInfo.textBlocks) {
          for (line in block.lines) {
            val lineText = line.text
            val lineBoundingBox: Rect? = line.boundingBox
            val map = WritableNativeMap()
            map.putString("text", lineText)
            map.putInt("height", image.height)
            map.putInt("width", image.width)
            val bounds = WritableNativeArray()
            bounds.pushInt(lineBoundingBox?.left)
            bounds.pushInt(lineBoundingBox?.bottom)
            bounds.pushInt(lineBoundingBox?.right)
            bounds.pushInt(lineBoundingBox?.top)
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
