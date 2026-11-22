package com.meshcore.meshcore_open

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val usbFunctions by lazy { MeshcoreUsbFunctions(this) }
    private val compassFunctions by lazy { CompassFunctions(this) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        usbFunctions.configureFlutterEngine(flutterEngine)
        compassFunctions.configureFlutterEngine(flutterEngine)
        // Back on the first screen sends the app to the background (like
        // Home) instead of closing it, which would drop the radio link.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "notoryx/app_task")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "moveTaskToBack" -> result.success(moveTaskToBack(true))
                    else -> result.notImplemented()
                }
            }
        // Screens holding secrets (SARNEG code words) block screenshots,
        // screen recording and the recent-apps preview while they're open.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "notoryx/screen_privacy")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecure" -> {
                        if (call.arguments == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        usbFunctions.dispose()
        compassFunctions.dispose()
        super.onDestroy()
    }
}
