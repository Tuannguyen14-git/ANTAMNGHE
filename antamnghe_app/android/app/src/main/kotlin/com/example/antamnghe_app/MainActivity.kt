package com.example.antamnghe_app

import android.os.Bundle
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "com.example.antamnghe_app/call_screening"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"setSpamList" -> {
					val list = call.argument<List<String>>("numbers") ?: emptyList()
					com.example.antamnghe_app.CallScreeningServiceImpl.spamSet.clear()
					com.example.antamnghe_app.CallScreeningServiceImpl.spamSet.addAll(list)
					result.success(true)
				}
				"setVipList" -> {
					val list = call.argument<List<String>>("numbers") ?: emptyList()
					com.example.antamnghe_app.CallScreeningServiceImpl.vipSet.clear()
					com.example.antamnghe_app.CallScreeningServiceImpl.vipSet.addAll(list)
					result.success(true)
				}
					"openAppSettings" -> {
						try {
							val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
							val uri = Uri.fromParts("package", applicationContext.packageName, null)
							intent.data = uri
							intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							startActivity(intent)
							result.success(true)
						} catch (e: Exception) {
							result.error("ERROR", "Failed to open settings: ${e.message}", null)
						}
					}
				else -> result.notImplemented()
			}
		}
	}
}
