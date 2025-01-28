package com.example.a_terminal

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

         MethodChannel(
             flutterEngine.dartExecutor.binaryMessenger,
             "native_call"
         ).setMethodCallHandler { call, result ->
             if (call.method == "showToast") {
                 showToast(call, result)
             } else {
                 result.notImplemented()
             }
         }
    }

     private fun showToast(call: MethodCall, result: MethodChannel.Result) {
         val duration =
             if (call.argument<Number>("duration") == 0) Toast.LENGTH_SHORT else Toast.LENGTH_LONG
         Toast.makeText(
             this,
             call.argument<String>("message"),
             duration
         ).show()
         result.success(null)
     }
}
