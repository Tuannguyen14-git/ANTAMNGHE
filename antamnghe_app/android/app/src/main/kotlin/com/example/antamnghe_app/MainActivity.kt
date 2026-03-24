package com.example.antamnghe_app

import android.Manifest
import android.app.role.RoleManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.pm.PackageManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "com.example.antamnghe_app/call_screening"
	private var pendingChannelResult: MethodChannel.Result? = null
	private var pendingRequestCode: Int? = null

	private companion object {
		const val REQUEST_CALL_SCREENING_ROLE = 4101
		const val REQUEST_SMS_PERMISSIONS = 4102
		const val REQUEST_NOTIFICATION_PERMISSION = 4103
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
			when (call.method) {
				"getSetupStatus" -> {
					val supportState = getCallScreeningSupportState()
					result.success(
						mapOf(
							"callScreeningSupported" to supportState.supported,
							"supportMessage" to supportState.message,
							"callScreeningEnabled" to isCallScreeningEnabled(),
							"smsPermissionsGranted" to hasSmsPermissions(),
							"notificationsGranted" to hasNotificationPermission(),
						),
					)
				}
				"getFocusWidgetStatus" -> {
					result.success(getFocusWidgetStatus())
				}
				"setSpamList" -> {
					val list = call.argument<List<String>>("numbers") ?: emptyList()
					ScreeningPreferences.setSpamList(applicationContext, list)
					result.success(true)
				}
				"setVipList" -> {
					val list = call.argument<List<String>>("numbers") ?: emptyList()
					ScreeningPreferences.setVipList(applicationContext, list)
					result.success(true)
				}
				"setFocusMode" -> {
					val durationMinutes = call.argument<Int>("durationMinutes") ?: 60
					ScreeningPreferences.enableFocusMode(applicationContext, durationMinutes)
					FocusModeWidgetProvider.refreshAll(applicationContext)
					result.success(true)
				}
				"clearFocusMode" -> {
					ScreeningPreferences.clearFocusMode(applicationContext)
					FocusModeWidgetProvider.refreshAll(applicationContext)
					result.success(true)
				}
				"setEmergencyKeywords" -> {
					val keywords = call.argument<List<String>>("keywords") ?: emptyList()
					ScreeningPreferences.setEmergencyKeywords(applicationContext, keywords)
					result.success(true)
				}
				"requestCallScreeningRole" -> {
					requestCallScreeningRole(result)
				}
				"requestSmsPermissions" -> {
					requestSmsPermissions(result)
				}
				"requestNotificationPermission" -> {
					requestNotificationPermission(result)
				}
				"requestPinFocusWidget" -> {
					result.success(requestPinFocusWidget())
				}
				"openDefaultAppsSettings" -> {
					try {
						val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
						intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
						startActivity(intent)
						result.success(true)
					} catch (e: Exception) {
						result.error("ERROR", "Failed to open default apps settings: ${e.message}", null)
					}
				}
				"openLauncherSettings" -> {
					result.success(openLauncherSettings())
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

	private fun getFocusWidgetStatus(): Map<String, Any> {
		val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
		val provider = ComponentName(applicationContext, FocusModeWidgetProvider::class.java)
		val pinnedCount = FocusModeWidgetProvider.getPinnedWidgetCount(applicationContext)
		val canRequestPin = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
			appWidgetManager.isRequestPinAppWidgetSupported

		val message = when {
			pinnedCount > 0 -> "Widget Smart Focus đã có trên màn hình chính. Bạn có thể bật hoặc tắt nhanh trong 1 chạm."
			canRequestPin -> "Launcher hỗ trợ ghim widget trực tiếp. Bạn có thể thêm Smart Focus ngay từ trong ứng dụng."
			else -> "Launcher hiện tại không hỗ trợ ghim nhanh từ app. Hãy nhấn giữ màn hình chính và thêm widget An Tâm Nghe thủ công."
		}

		return mapOf(
			"isPinned" to (pinnedCount > 0),
			"canRequestPin" to canRequestPin,
			"message" to message,
		)
	}

	private fun requestPinFocusWidget(): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
			return false
		}

		val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
		if (!appWidgetManager.isRequestPinAppWidgetSupported) {
			return false
		}

		val provider = ComponentName(applicationContext, FocusModeWidgetProvider::class.java)
		return appWidgetManager.requestPinAppWidget(provider, null, null)
	}

	private fun openLauncherSettings(): Boolean {
		val intents = listOf(
			Intent(Settings.ACTION_HOME_SETTINGS),
			Intent("android.settings.HOME_SETTINGS"),
			Intent(Settings.ACTION_SETTINGS),
		)

		for (intent in intents) {
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
			if (intent.resolveActivity(packageManager) != null) {
				startActivity(intent)
				return true
			}
		}

		return false
	}

	private data class CallScreeningSupportState(
		val supported: Boolean,
		val message: String,
	)

	private fun getCallScreeningSupportState(): CallScreeningSupportState {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
			return CallScreeningSupportState(
				false,
				"Thiết bị đang chạy Android quá cũ để bật Call Screening theo thời gian thực.",
			)
		}

		val roleManager = getSystemService(RoleManager::class.java)
		if (roleManager == null) {
			return CallScreeningSupportState(
				false,
				"Thiết bị không cung cấp RoleManager nên không thể đăng ký bộ lọc cuộc gọi.",
			)
		}

		if (!roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
			return CallScreeningSupportState(
				false,
				"ROM hiện tại không hỗ trợ vai trò Call Screening cho ứng dụng bên thứ ba.",
			)
		}

		return CallScreeningSupportState(
			true,
			"Thiết bị hỗ trợ Call Screening đầy đủ. Hoàn tất các quyền bên dưới để bật chế độ bảo vệ.",
		)
	}

	private fun isCallScreeningEnabled(): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
			return false
		}
		val roleManager = getSystemService(RoleManager::class.java) ?: return false
		return roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING) &&
			roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
	}

	private fun hasSmsPermissions(): Boolean {
		return hasPermission(Manifest.permission.RECEIVE_SMS) &&
			hasPermission(Manifest.permission.READ_SMS)
	}

	private fun hasNotificationPermission(): Boolean {
		return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
			hasPermission(Manifest.permission.POST_NOTIFICATIONS)
		} else {
			NotificationManagerCompat.from(applicationContext).areNotificationsEnabled()
		}
	}

	private fun hasPermission(permission: String): Boolean {
		return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
	}

	private fun requestCallScreeningRole(result: MethodChannel.Result) {
		if (isCallScreeningEnabled()) {
			result.success(true)
			return
		}

		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
			result.success(false)
			return
		}

		val roleManager = getSystemService(RoleManager::class.java)
		if (roleManager == null || !roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
			result.success(false)
			return
		}

		pendingChannelResult = result
		pendingRequestCode = REQUEST_CALL_SCREENING_ROLE
		startActivityForResult(
			roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING),
			REQUEST_CALL_SCREENING_ROLE,
		)
	}

	private fun requestSmsPermissions(result: MethodChannel.Result) {
		if (hasSmsPermissions()) {
			result.success(true)
			return
		}

		pendingChannelResult = result
		pendingRequestCode = REQUEST_SMS_PERMISSIONS
		ActivityCompat.requestPermissions(
			this,
			arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
			REQUEST_SMS_PERMISSIONS,
		)
	}

	private fun requestNotificationPermission(result: MethodChannel.Result) {
		if (hasNotificationPermission()) {
			result.success(true)
			return
		}

		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
			result.success(NotificationManagerCompat.from(applicationContext).areNotificationsEnabled())
			return
		}

		pendingChannelResult = result
		pendingRequestCode = REQUEST_NOTIFICATION_PERMISSION
		ActivityCompat.requestPermissions(
			this,
			arrayOf(Manifest.permission.POST_NOTIFICATIONS),
			REQUEST_NOTIFICATION_PERMISSION,
		)
	}

	override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
		super.onActivityResult(requestCode, resultCode, data)
		if (requestCode == REQUEST_CALL_SCREENING_ROLE && pendingRequestCode == REQUEST_CALL_SCREENING_ROLE) {
			pendingChannelResult?.success(isCallScreeningEnabled())
			pendingChannelResult = null
			pendingRequestCode = null
		}
	}

	override fun onRequestPermissionsResult(
		requestCode: Int,
		permissions: Array<out String>,
		grantResults: IntArray,
	) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)
		if (requestCode != pendingRequestCode) {
			return
		}

		val isGranted = when (requestCode) {
			REQUEST_SMS_PERMISSIONS -> hasSmsPermissions()
			REQUEST_NOTIFICATION_PERMISSION -> hasNotificationPermission()
			else -> false
		}

		pendingChannelResult?.success(isGranted)
		pendingChannelResult = null
		pendingRequestCode = null
	}
}
