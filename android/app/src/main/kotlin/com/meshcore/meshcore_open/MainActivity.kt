package com.meshcore.meshcore_open

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
    }

    override fun onDestroy() {
        usbFunctions.dispose()
        compassFunctions.dispose()
        super.onDestroy()
    }
}
