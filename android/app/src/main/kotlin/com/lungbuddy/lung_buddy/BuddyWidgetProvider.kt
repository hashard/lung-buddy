package com.lungbuddy.lung_buddy

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
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
            val openApp =
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            setOnClickPendingIntent(R.id.widget_root, openApp)
            setOnClickPendingIntent(R.id.widget_buddy, openApp)

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

            val imagePath = widgetData.getString("buddyImage", null)
            if (imagePath != null) {
              val bitmap = BitmapFactory.decodeFile(imagePath)
              if (bitmap != null) {
                setImageViewBitmap(R.id.widget_buddy, bitmap)
              } else {
                setImageViewResource(R.id.widget_buddy, R.drawable.buddy_widget_mascot)
              }
            } else {
              setImageViewResource(R.id.widget_buddy, R.drawable.buddy_widget_mascot)
            }

            val locked = widgetData.getBoolean("locked", true)
            if (locked) {
              setTextViewText(R.id.widget_smoke_btn, "PLUS")
              setOnClickPendingIntent(
                  R.id.widget_smoke_btn,
                  HomeWidgetLaunchIntent.getActivity(
                      context,
                      MainActivity::class.java,
                      Uri.parse("lungbuddy://plus"),
                  ),
              )
            } else {
              setTextViewText(R.id.widget_smoke_btn, "I smoked")
              setOnClickPendingIntent(
                  R.id.widget_smoke_btn,
                  HomeWidgetBackgroundIntent.getBroadcast(
                      context,
                      Uri.parse("lungbuddy://smoke"),
                  ),
              )
            }
            setViewVisibility(R.id.widget_smoke_btn, View.VISIBLE)
          }
      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
