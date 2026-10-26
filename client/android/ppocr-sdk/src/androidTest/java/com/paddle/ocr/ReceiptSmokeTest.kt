package com.paddle.ocr

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.paddle.ocr.util.OpenCVUtils
import kotlinx.coroutines.runBlocking
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.Assume.assumeTrue
import java.io.File
import org.json.JSONArray
import org.json.JSONObject

/** Exercises the actual bundled models and native libraries, not a mock. */
@RunWith(AndroidJUnit4::class)
class ReceiptSmokeTest {
    /** Optional local diagnostic. The photo and export never enter the app APK. */
    @Test
    fun exportProvidedPhoto() = runBlocking {
        val filename = InstrumentationRegistry.getArguments().getString("receipt_file")
        assumeTrue("No diagnostic photo supplied", filename != null)
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        assertTrue(OpenCVUtils.init(context))
        val ocr = PaddleOCR.create(context, PaddleOCRConfig(
            detLimitType = "max", detLimitSideLen = 1600, detMaxSideLimit = 1600,
            recScoreThresh = 0.35f, detThresh = 0.2f, detBoxThresh = 0.4f, detUnclipRatio = 1.4f,
        ))
        try {
            val result = ocr.recognize(File(context.filesDir, filename!!).readBytes())
            val rows = JSONArray()
            result.results.forEach { line -> rows.put(JSONObject().apply {
                put("text", line.text)
                put("left", line.box.points.minOf { it.x })
                put("right", line.box.points.maxOf { it.x })
                put("top", line.box.points.minOf { it.y })
                put("bottom", line.box.points.maxOf { it.y })
                put("points", JSONArray(line.box.points.map { JSONArray(listOf(it.x, it.y)) }))
            }) }
            File(context.filesDir, "receipt-ocr.json").writeText(rows.toString(2))
            assertTrue(result.results.isNotEmpty())
        } finally { ocr.release() }
    }

    @Test
    fun readsReceiptAndBlankImage() = runBlocking {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        assertTrue(OpenCVUtils.init(context))
        val ocr = PaddleOCR.create(context, PaddleOCRConfig(
            detLimitType = "max", detLimitSideLen = 1600,
            detMaxSideLimit = 1600, recScoreThresh = 0.35f,
            detThresh = 0.2f, detBoxThresh = 0.4f, detUnclipRatio = 1.4f,
        ))
        val bitmap = Bitmap.createBitmap(900, 700, Bitmap.Config.ARGB_8888)
        try {
            val canvas = Canvas(bitmap)
            canvas.drawColor(Color.WHITE)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.BLACK
                textSize = 42f
                typeface = Typeface.MONOSPACE
            }
            listOf("CAFE RECEIPT", "Coffee    150.00", "Toast      99.50", "GST        12.50", "TOTAL     262.00")
                .forEachIndexed { index, text -> canvas.drawText(text, 80f, 100f + index * 100f, paint) }
            val result = ocr.recognize(bitmap)
            val text = result.results.joinToString("\n") { it.text }
            assertTrue(text, text.contains("Coffee", ignoreCase = true))
            assertTrue(text, text.contains("150.00"))
            assertTrue(text, text.contains("262.00"))
            assertTrue(result.results.all { line -> line.box.points.all { it.x >= 0 && it.y >= 0 } })
            canvas.drawColor(Color.WHITE)
            assertTrue(ocr.recognize(bitmap).results.isEmpty())
        } finally {
            ocr.release()
            bitmap.recycle()
        }
    }
}
