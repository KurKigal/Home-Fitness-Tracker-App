package com.emirhankeser.fitnesstracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.time.LocalDate

class FitnessWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val rawSchedule =
            widgetData.getString(
                "widget_schedule",
                "{}"
            ) ?: "{}"

        val schedule = try {
            JSONObject(rawSchedule)
        } catch (_: Exception) {
            JSONObject()
        }

        val programStart = try {
            LocalDate.parse(
                widgetData.getString(
                    "widget_program_start",
                    "2026-09-01"
                )
            )
        } catch (_: Exception) {
            LocalDate.of(
                2026,
                9,
                1
            )
        }

        val firstWorkout =
            widgetData.getString(
                "widget_first_workout",
                "Kuvvet A"
            ) ?: "Kuvvet A"

        val today = LocalDate.now()

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.fitness_widget
            )

            if (today.isBefore(programStart)) {
                renderPreStart(
                    views = views,
                    startDate = programStart,
                    firstWorkout = firstWorkout
                )
            } else {
                renderToday(
                    views = views,
                    schedule = schedule,
                    today = today
                )
            }

            attachLaunchIntent(
                context = context,
                views = views,
                widgetId = widgetId
            )

            appWidgetManager.updateAppWidget(
                widgetId,
                views
            )
        }
    }

    private fun renderPreStart(
        views: RemoteViews,
        startDate: LocalDate,
        firstWorkout: String
    ) {
        views.setTextViewText(
            R.id.widget_status,
            "PROGRAM"
        )

        views.setTextViewText(
            R.id.widget_title,
            "Program yakında başlıyor"
        )

        views.setTextViewText(
            R.id.widget_meta,
            "${formatShortDate(startDate)} • $firstWorkout"
        )

        views.setTextViewText(
            R.id.widget_next,
            "Hazır olduğunda uygulamadan programı inceleyebilirsin."
        )

        views.setTextViewText(
            R.id.widget_action,
            "AÇ"
        )
    }

    private fun renderToday(
        views: RemoteViews,
        schedule: JSONObject,
        today: LocalDate
    ) {
        val data =
            schedule.optJSONObject(
                today.toString()
            )

        if (data == null) {
            renderMissingData(
                views
            )
            return
        }

        val title =
            data.optString(
                "title",
                "Antrenman"
            )

        val phase =
            data.optString(
                "phase",
                ""
            )

        val duration =
            data.optInt(
                "duration",
                0
            )

        val itemCount =
            data.optInt(
                "itemCount",
                0
            )

        val itemType =
            data.optString(
                "itemType",
                ""
            )

        val status =
            data.optString(
                "status",
                "planned"
            )

        val isRest =
            data.optBoolean(
                "rest",
                false
            )

        when {
            isRest -> {
                views.setTextViewText(
                    R.id.widget_status,
                    "DİNLENME"
                )

                views.setTextViewText(
                    R.id.widget_title,
                    "Dinlenme Günü"
                )

                views.setTextViewText(
                    R.id.widget_meta,
                    "Bugün toparlanma günü"
                )
            }

            status == "completed" -> {
                views.setTextViewText(
                    R.id.widget_status,
                    "✓ TAMAMLANDI"
                )

                views.setTextViewText(
                    R.id.widget_title,
                    title
                )

                views.setTextViewText(
                    R.id.widget_meta,
                    "Bugünkü antrenman tamamlandı"
                )
            }

            status == "skipped" -> {
                views.setTextViewText(
                    R.id.widget_status,
                    "ATLANDI"
                )

                views.setTextViewText(
                    R.id.widget_title,
                    title
                )

                views.setTextViewText(
                    R.id.widget_meta,
                    "Program yarın normal şekilde devam edecek"
                )
            }

            status == "postponed" -> {
                views.setTextViewText(
                    R.id.widget_status,
                    "ERTELENDİ"
                )

                views.setTextViewText(
                    R.id.widget_title,
                    title
                )

                views.setTextViewText(
                    R.id.widget_meta,
                    "Program 1 gün ileri kaydırıldı"
                )
            }

            else -> {
                views.setTextViewText(
                    R.id.widget_status,
                    "BUGÜN"
                )

                views.setTextViewText(
                    R.id.widget_title,
                    title
                )

                val detailParts =
                    mutableListOf<String>()

                if (duration > 0) {
                    detailParts.add(
                        "~$duration dk"
                    )
                }

                if (
                    itemCount > 0 &&
                    itemType.isNotBlank()
                ) {
                    detailParts.add(
                        "$itemCount $itemType"
                    )
                }

                views.setTextViewText(
                    R.id.widget_meta,
                    detailParts.joinToString(
                        " • "
                    )
                )
            }
        }

        val nextTraining =
            findNextTraining(
                schedule = schedule,
                from = today.plusDays(1)
            )

        val nextText =
            if (nextTraining != null) {
                val date =
                    nextTraining.first

                val nextTitle =
                    nextTraining.second

                "Sıradaki: ${formatShortDate(date)} • $nextTitle"
            } else if (phase.isNotBlank()) {
                phase
            } else {
                "Fitness Tracker"
            }

        views.setTextViewText(
            R.id.widget_next,
            nextText
        )

        views.setTextViewText(
            R.id.widget_action,
            if (
                status == "planned" &&
                !isRest
            ) {
                "BAŞLA"
            } else {
                "AÇ"
            }
        )
    }

    private fun renderMissingData(
        views: RemoteViews
    ) {
        views.setTextViewText(
            R.id.widget_status,
            "FITNESS"
        )

        views.setTextViewText(
            R.id.widget_title,
            "Programı güncelle"
        )

        views.setTextViewText(
            R.id.widget_meta,
            "Güncel programı almak için uygulamayı aç."
        )

        views.setTextViewText(
            R.id.widget_next,
            "Fitness Tracker"
        )

        views.setTextViewText(
            R.id.widget_action,
            "AÇ"
        )
    }

    private fun findNextTraining(
        schedule: JSONObject,
        from: LocalDate
    ): Pair<LocalDate, String>? {
        var date = from

        repeat(370) {
            val data =
                schedule.optJSONObject(
                    date.toString()
                )

            if (data != null) {
                val isRest =
                    data.optBoolean(
                        "rest",
                        false
                    )

                val status =
                    data.optString(
                        "status",
                        "planned"
                    )

                if (
                    !isRest &&
                    status == "planned"
                ) {
                    return Pair(
                        date,
                        data.optString(
                            "title",
                            "Antrenman"
                        )
                    )
                }
            }

            date = date.plusDays(1)
        }

        return null
    }

    private fun attachLaunchIntent(
        context: Context,
        views: RemoteViews,
        widgetId: Int
    ) {
        val intent = Intent(
            context,
            MainActivity::class.java
        ).apply {
            flags =
                Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent =
            PendingIntent.getActivity(
                context,
                widgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

        views.setOnClickPendingIntent(
            R.id.widget_root,
            pendingIntent
        )

        views.setOnClickPendingIntent(
            R.id.widget_action,
            pendingIntent
        )
    }

    private fun formatShortDate(
        date: LocalDate
    ): String {
        val months = arrayOf(
            "Oca",
            "Şub",
            "Mar",
            "Nis",
            "May",
            "Haz",
            "Tem",
            "Ağu",
            "Eyl",
            "Eki",
            "Kas",
            "Ara"
        )

        return "${date.dayOfMonth} ${months[date.monthValue - 1]}"
    }
}