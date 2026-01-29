package com.burbly.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Main Activity with MethodChannel bridge for scheduling alarms.
 * Handles communication between Flutter and native Android alarm system.
 */
class MainActivity : FlutterActivity() {
    
    private val CHANNEL = "com.burbly.app/notifications"
    private val TAG = "MainActivity"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize notification channels
        NotificationHelper.createNotificationChannels(this)
        
        // Setup MethodChannel for Flutter communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleReminder" -> {
                    try {
                        val reminderId = call.argument<Int>("reminderId")
                        val notificationType = call.argument<String>("notificationType")
                        val title = call.argument<String>("title")
                        val message = call.argument<String>("message")
                        val scheduledTime = call.argument<Long>("scheduledTime")
                        val deckName = call.argument<String>("deckName")
                        val cardCount = call.argument<Int>("cardCount")
                        val deckId = call.argument<String>("deckId")
                        
                        if (reminderId == null || scheduledTime == null) {
                            result.error("INVALID_ARGS", "Missing required arguments", null)
                            return@setMethodCallHandler
                        }
                        
                        scheduleAlarm(
                            reminderId = reminderId,
                            notificationType = notificationType ?: AlarmReceiver.TYPE_STUDY_REMINDER,
                            title = title ?: "Study Reminder",
                            message = message ?: "Time to study!",
                            scheduledTime = scheduledTime,
                            deckName = deckName,
                            cardCount = cardCount ?: 0,
                            deckId = deckId
                        )
                        
                        result.success(true)
                        Log.d(TAG, "Scheduled reminder: $reminderId at $scheduledTime")
                        
                    } catch (e: Exception) {
                        Log.e(TAG, "Error scheduling reminder", e)
                        result.error("SCHEDULE_ERROR", e.message, null)
                    }
                }
                
                "cancelReminder" -> {
                    try {
                        val reminderId = call.argument<Int>("reminderId")
                        
                        if (reminderId == null) {
                            result.error("INVALID_ARGS", "Missing reminderId", null)
                            return@setMethodCallHandler
                        }
                        
                        cancelAlarm(reminderId)
                        result.success(true)
                        Log.d(TAG, "Cancelled reminder: $reminderId")
                        
                    } catch (e: Exception) {
                        Log.e(TAG, "Error cancelling reminder", e)
                        result.error("CANCEL_ERROR", e.message, null)
                    }
                }
                
                "rescheduleAll" -> {
                    try {
                        val reminders = call.argument<List<Map<String, Any>>>("reminders")
                        
                        if (reminders == null) {
                            result.error("INVALID_ARGS", "Missing reminders list", null)
                            return@setMethodCallHandler
                        }
                        
                        var successCount = 0
                        for (reminder in reminders) {
                            try {
                                scheduleAlarm(
                                    reminderId = reminder["reminderId"] as Int,
                                    notificationType = reminder["notificationType"] as? String ?: AlarmReceiver.TYPE_STUDY_REMINDER,
                                    title = reminder["title"] as? String ?: "Study Reminder",
                                    message = reminder["message"] as? String ?: "Time to study!",
                                    scheduledTime = (reminder["scheduledTime"] as Number).toLong(),
                                    deckName = reminder["deckName"] as? String,
                                    cardCount = reminder["cardCount"] as? Int ?: 0,
                                    deckId = reminder["deckId"] as? String
                                )
                                successCount++
                            } catch (e: Exception) {
                                Log.e(TAG, "Error rescheduling reminder: ${reminder["reminderId"]}", e)
                            }
                        }
                        
                        result.success(successCount)
                        Log.d(TAG, "Rescheduled $successCount reminders")
                        
                    } catch (e: Exception) {
                        Log.e(TAG, "Error rescheduling all", e)
                        result.error("RESCHEDULE_ERROR", e.message, null)
                    }
                }
                
                "checkNeedsReschedule" -> {
                    try {
                        val needs = BootReceiver().needsReschedule(this)
                        result.success(needs)
                        Log.d(TAG, "Needs reschedule: $needs")
                    } catch (e: Exception) {
                        Log.e(TAG, "Error checking reschedule", e)
                        result.error("CHECK_ERROR", e.message, null)
                    }
                }
                
                "canScheduleExactAlarms" -> {
                    try {
                        val canSchedule = canScheduleExactAlarms()
                        result.success(canSchedule)
                    } catch (e: Exception) {
                        result.error("CHECK_ERROR", e.message, null)
                    }
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Check if we need to reschedule on app start
        checkAndNotifyReschedule(flutterEngine)
        
        // Handle notification intent if app was opened from notification
        handleNotificationIntent(intent)
    }
    
    /**
     * Handle new intents (e.g., from notification taps)
     */
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleNotificationIntent(intent)
    }
    
    /**
     * Handle notification intent and navigate to deck if present
     */
    private fun handleNotificationIntent(intent: Intent?) {
        if (intent == null) return
        
        val notificationType = intent.getStringExtra("notification_type")
        val deckId = intent.getStringExtra("deck_id")
        
        Log.d(TAG, "Handling notification intent: type=$notificationType, deckId=$deckId")
        
        if (notificationType == "flashcard_review" && !deckId.isNullOrEmpty()) {
            // Send to Flutter to navigate to deck
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod(
                    "openDeck",
                    mapOf("deckId" to deckId)
                )
                Log.d(TAG, "Sent openDeck command to Flutter for deck: $deckId")
            }
        }
    }
    
    /**
     * Schedule an alarm using AlarmManager
     */
    private fun scheduleAlarm(
        reminderId: Int,
        notificationType: String,
        title: String,
        message: String,
        scheduledTime: Long,
        deckName: String?,
        cardCount: Int,
        deckId: String? = null
    ) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra(AlarmReceiver.EXTRA_NOTIFICATION_TYPE, notificationType)
            putExtra(AlarmReceiver.EXTRA_NOTIFICATION_ID, reminderId)
            putExtra(AlarmReceiver.EXTRA_TITLE, title)
            putExtra(AlarmReceiver.EXTRA_MESSAGE, message)
            deckName?.let { putExtra(AlarmReceiver.EXTRA_DECK_NAME, it) }
            putExtra(AlarmReceiver.EXTRA_CARD_COUNT, cardCount)
            deckId?.let { putExtra(AlarmReceiver.EXTRA_DECK_ID, it) }
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            reminderId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        try {
            // Try to use exact alarm if possible, fallback to inexact
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (canScheduleExactAlarms()) {
                    // Use exact alarm for better precision
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        scheduledTime,
                        pendingIntent
                    )
                    Log.d(TAG, "Scheduled exact alarm for $reminderId")
                } else {
                    // Fallback to inexact alarm
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        scheduledTime,
                        pendingIntent
                    )
                    Log.d(TAG, "Scheduled inexact alarm for $reminderId")
                }
            } else {
                alarmManager.set(
                    AlarmManager.RTC_WAKEUP,
                    scheduledTime,
                    pendingIntent
                )
                Log.d(TAG, "Scheduled basic alarm for $reminderId")
            }
        } catch (e: SecurityException) {
            // If exact alarm fails, use inexact
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                scheduledTime,
                pendingIntent
            )
            Log.w(TAG, "Fell back to inexact alarm for $reminderId", e)
        }
    }
    
    /**
     * Cancel a scheduled alarm
     */
    private fun cancelAlarm(reminderId: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            reminderId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }
    
    /**
     * Check if the app can schedule exact alarms
     */
    private fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true // Older versions don't have this restriction
        }
    }
    
    /**
     * Check if alarms need rescheduling and notify Flutter
     */
    private fun checkAndNotifyReschedule(flutterEngine: FlutterEngine) {
        val needs = BootReceiver().needsReschedule(this)
        if (needs) {
            Log.d(TAG, "Notifying Flutter that alarms need rescheduling")
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("onNeedsReschedule", null)
        }
    }
}
