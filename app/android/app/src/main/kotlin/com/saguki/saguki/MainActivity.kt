package com.saguki.saguki

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // In-app updater (update.dart): open a downloaded APK in the system installer, which
        // asks for "install unknown apps" the first time.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "saguki/update").setMethodCallHandler { call, result ->
            val uri = FileProvider.getUriForFile(this, "$packageName.update", File(call.arguments as String))
            startActivity(
                Intent(Intent.ACTION_VIEW)
                    .setDataAndType(uri, "application/vnd.android.package-archive")
                    .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
            )
            result.success(null)
        }
    }
}
