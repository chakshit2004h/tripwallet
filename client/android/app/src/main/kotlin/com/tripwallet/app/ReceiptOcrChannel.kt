package com.tripwallet.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import androidx.exifinterface.media.ExifInterface
import com.paddle.ocr.PaddleOCR
import com.paddle.ocr.PaddleOCRConfig
import com.paddle.ocr.util.OpenCVUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex

/** One inference at a time, off the UI thread, with no photo uploads. */
class ReceiptOcrChannel(private val context: Context, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "com.tripwallet.app/receipt_ocr")
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val mutex = Mutex()

    init {
        channel.setMethodCallHandler { call, result ->
            if (call.method != "recognize") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val path = call.argument<String>("path")
            if (path.isNullOrBlank()) {
                result.error("invalid_image", "Choose a receipt photo.", null)
                return@setMethodCallHandler
            }
            if (!mutex.tryLock()) {
                result.error("ocr_busy", "A receipt is already being read.", null)
                return@setMethodCallHandler
            }
            scope.launch {
                try {
                    val lines = withContext(Dispatchers.IO) { recognize(path) }
                    result.success(lines)
                } catch (e: CancellationException) {
                    throw e
                } catch (e: Exception) {
                    result.error("ocr_failed", "Could not read this receipt photo.", null)
                } catch (e: LinkageError) {
                    result.error("ocr_unavailable", "The receipt scanner could not start on this device.", null)
                } finally {
                    mutex.unlock()
                }
            }
        }
    }

    private suspend fun recognize(path: String): List<Map<String, Any>> {
        check(OpenCVUtils.init(context)) { "OpenCV initialization failed" }
        val bitmap = loadPhoto(path)
        var ocr: PaddleOCR? = null
        try {
            // Bound detection memory on phones while retaining small receipt text.
            val engine = PaddleOCR.create(context, PaddleOCRConfig(
                detLimitType = "max", detLimitSideLen = 1600,
                detMaxSideLimit = 1600, recScoreThresh = 0.35f,
                detThresh = 0.2f, detBoxThresh = 0.4f, detUnclipRatio = 1.4f,
            ))
            ocr = engine
            return engine.recognize(bitmap).results.map { line ->
                mapOf(
                    "text" to line.text,
                    "confidence" to line.confidence.toDouble(),
                    "left" to line.box.points.minOf { it.x }.toDouble(),
                    "top" to line.box.points.minOf { it.y }.toDouble(),
                    "right" to line.box.points.maxOf { it.x }.toDouble(),
                    "bottom" to line.box.points.maxOf { it.y }.toDouble(),
                )
            }
        } finally {
            withContext(NonCancellable) { ocr?.release() }
            bitmap.recycle()
        }
    }

    private fun loadPhoto(path: String): Bitmap {
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, options)
        require(options.outWidth > 0 && options.outHeight > 0) { "Invalid image" }
        var sample = 1
        while (maxOf(options.outWidth, options.outHeight) / sample > 2400) sample *= 2
        options.inJustDecodeBounds = false
        options.inSampleSize = sample
        options.inPreferredConfig = Bitmap.Config.ARGB_8888
        val bitmap = requireNotNull(BitmapFactory.decodeFile(path, options))
        try {
            val exif = ExifInterface(path)
            val matrix = Matrix()
            if (exif.isFlipped) matrix.postScale(-1f, 1f)
            matrix.postRotate(exif.rotationDegrees.toFloat())
            if (matrix.isIdentity) return bitmap
            val upright = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
            if (upright !== bitmap) bitmap.recycle()
            return upright
        } catch (e: Exception) {
            bitmap.recycle()
            throw e
        }
    }

    fun close() {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }
}
