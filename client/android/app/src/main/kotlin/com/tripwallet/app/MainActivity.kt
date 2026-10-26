package com.tripwallet.app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var receiptOcr: ReceiptOcrChannel? = null
    private var payments: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        receiptOcr = ReceiptOcrChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        payments = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tripwallet/payments").also { channel ->
            channel.setMethodCallHandler { call, result ->
                if (call.method != "openUpi") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val raw = call.argument<String>("uri")
                val target = call.argument<String>("package")
                val allowedPackages = setOf("com.google.android.apps.nbu.paisa.user", "com.phonepe.app", "net.one97.paytm")
                val uri = raw?.let { Uri.parse(it) }
                // This channel can open only a one-time INR payment, never an arbitrary URL or mandate.
                if (uri == null || uri.scheme != "upi" || uri.authority != "pay" ||
                    !uri.path.isNullOrEmpty() || uri.fragment != null ||
                    uri.queryParameterNames != setOf("pa", "pn", "am", "cu", "tn") ||
                    uri.queryParameterNames.any { uri.getQueryParameters(it).size != 1 } ||
                    uri.getQueryParameter("cu") != "INR" ||
                    !Regex("^[A-Za-z0-9._-]{2,256}@[A-Za-z0-9.-]{2,64}$").matches(uri.getQueryParameter("pa") ?: "") ||
                    !Regex("^[0-9]+[.][0-9]{2}$").matches(uri.getQueryParameter("am") ?: "") ||
                    (uri.getQueryParameter("am")?.toBigDecimalOrNull()?.signum() ?: 0) <= 0 ||
                    (target != null && target !in allowedPackages)) {
                    result.error("invalid_payment", "Invalid payment details", null)
                    return@setMethodCallHandler
                }
                try {
                    val intent = Intent(Intent.ACTION_VIEW, uri).addCategory(Intent.CATEGORY_BROWSABLE)
                    if (target != null) intent.setPackage(target)
                    startActivity(if (target == null) Intent.createChooser(intent, "Pay with") else intent)
                    // Launch success is not transaction success. Never consume payment callbacks as proof.
                    result.success(true)
                } catch (_: ActivityNotFoundException) {
                    result.success(false)
                } catch (_: SecurityException) {
                    result.success(false)
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        payments?.setMethodCallHandler(null)
        payments = null
        receiptOcr?.close()
        receiptOcr = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
