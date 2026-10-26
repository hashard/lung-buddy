package com.lungbuddy.lung_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BuddyWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.buddy_widget).apply {
            val pendingIntent =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            setTextViewText(
                R.id.widget_title,
                widgetData.getString("title", null) ?: "Lung Buddy",
            )
            setTextViewText(
                R.id.widget_line,
                widgetData.getString("line", null) ?: "Open the app to refresh",
            )
            setTextViewText(
                R.id.widget_streak,
                widgetData.getString("streak", null) ?: "Streak —",
            )
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
