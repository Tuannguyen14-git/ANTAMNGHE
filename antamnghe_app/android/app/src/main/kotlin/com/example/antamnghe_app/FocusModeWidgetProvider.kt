package com.example.antamnghe_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class FocusModeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_TOGGLE_FOCUS_MODE) {
            if (ScreeningPreferences.isFocusModeActive(context)) {
                ScreeningPreferences.clearFocusMode(context)
            } else {
                ScreeningPreferences.enableFocusMode(context, 60)
            }
            refreshAll(context)
        }
    }

    companion object {
        private const val ACTION_TOGGLE_FOCUS_MODE = "com.example.antamnghe_app.TOGGLE_FOCUS_MODE"

        fun getPinnedWidgetCount(context: Context): Int {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, FocusModeWidgetProvider::class.java)
            return manager.getAppWidgetIds(component).size
        }

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, FocusModeWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            ids.forEach { appWidgetId ->
                updateWidget(context, manager, appWidgetId)
            }
        }

        private fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val isActive = ScreeningPreferences.isFocusModeActive(context)
            val toggleIntent = Intent(context, FocusModeWidgetProvider::class.java).apply {
                action = ACTION_TOGGLE_FOCUS_MODE
            }
            val togglePendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId,
                toggleIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val launchIntent = Intent(context, MainActivity::class.java)
            val launchPendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId + 1000,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

            val views = RemoteViews(context.packageName, R.layout.focus_mode_widget)
            views.setTextViewText(
                R.id.widget_status,
                if (isActive) "Smart Focus đang bật" else "Smart Focus đang tắt",
            )
            views.setTextViewText(
                R.id.widget_button,
                if (isActive) "Tắt ngay" else "Bật 1 giờ",
            )
            views.setOnClickPendingIntent(R.id.widget_root, launchPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_button, togglePendingIntent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
