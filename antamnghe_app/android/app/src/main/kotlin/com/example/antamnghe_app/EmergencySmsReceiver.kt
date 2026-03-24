package com.example.antamnghe_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class EmergencySmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            return
        }

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isEmpty()) return

        val sender = messages.firstOrNull()?.originatingAddress.orEmpty()
        val body = messages.joinToString(separator = " ") { it.messageBody.orEmpty() }
        handleMessage(context, sender, body)
    }

    fun handleMessage(context: Context, sender: String, body: String): Boolean {
        if (sender.isBlank() || body.isBlank()) return false

        val keywords = ScreeningPreferences.getEmergencyKeywords(context)
        if (keywords.isEmpty()) return false

        val normalizedBody = body.lowercase()
        val matched = keywords.any { keyword -> normalizedBody.contains(keyword) }
        if (!matched) return false

        ScreeningPreferences.allowTemporaryNumber(context, sender, 60 * 60 * 1000L)
        showNotification(context, sender, body)
        return true
    }

    private fun showNotification(context: Context, sender: String, body: String) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Emergency SMS",
                NotificationManager.IMPORTANCE_HIGH,
            )
            channel.description = "Alerts when an emergency SMS temporarily unlocks a caller"
            manager.createNotificationChannel(channel)
        }

        val launchIntent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            301,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_notify_more)
            .setContentTitle("Tin nhắn khẩn cấp từ $sender")
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        NotificationManagerCompat.from(context).notify(sender.hashCode(), notification)
    }

    companion object {
        private const val CHANNEL_ID = "emergency_sms_alerts"
    }
}
