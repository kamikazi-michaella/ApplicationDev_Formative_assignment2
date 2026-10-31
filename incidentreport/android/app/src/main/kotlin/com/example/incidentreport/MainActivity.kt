package com.example.incidentreport

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val photoPickerRequest = 7401
    private var photoPickerResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "campus_connect/photo_picker"
        ).setMethodCallHandler { call, result ->
            if (call.method != "pickImage") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            if (photoPickerResult != null) {
                result.error("picker_in_use", "The photo picker is already open.", null)
                return@setMethodCallHandler
            }

            photoPickerResult = result
            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                type = "image/*"
                addCategory(Intent.CATEGORY_OPENABLE)
            }
            try {
                startActivityForResult(intent, photoPickerRequest)
            } catch (error: android.content.ActivityNotFoundException) {
                photoPickerResult = null
                result.error("picker_unavailable", "No photo picker is available.", null)
            }
        }
    }

    @Deprecated("Use Activity Result APIs when supported by the Flutter activity.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != photoPickerRequest) return

        val result = photoPickerResult ?: return
        photoPickerResult = null
        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }

        val uri = data?.data
        if (uri == null) {
            result.error("photo_unavailable", "The selected photo could not be read.", null)
            return
        }
        try {
            result.success(copyPhotoToCache(uri).absolutePath)
        } catch (error: IOException) {
            result.error("photo_read_failed", "The selected photo could not be copied.", null)
        }
    }

    @Throws(IOException::class)
    private fun copyPhotoToCache(uri: Uri): File {
        val extension = when (contentResolver.getType(uri)) {
            "image/png" -> ".png"
            "image/webp" -> ".webp"
            else -> ".jpg"
        }
        val destination = File(cacheDir, "incident-${System.currentTimeMillis()}$extension")
        contentResolver.openInputStream(uri).use { input ->
            if (input == null) throw IOException("Could not open selected photo.")
            destination.outputStream().use { output -> input.copyTo(output) }
        }
        return destination
    }
}
