package com.burbly.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * Handles notification creation and channel management.
 * Optimized for battery life and Play Store compliance.
 */
object NotificationHelper {
    
    // Notification Channel IDs
    const val CHANNEL_ID_STUDY_REMINDERS = "study_reminders"
    const val CHANNEL_ID_FLASHCARD_REVIEW = "flashcard_review"
    const val CHANNEL_ID_DAILY_GOALS = "daily_goals"
    
    // Notification IDs
    const val NOTIFICATION_ID_STUDY_REMINDER = 1001
    const val NOTIFICATION_ID_FLASHCARD_REVIEW = 1002
    const val NOTIFICATION_ID_DAILY_GOAL = 1003
    
    /**
     * Initialize notification channels (call once at app start)
     */
    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Study Reminders Channel - High Priority
            val studyChannel = NotificationChannel(
                CHANNEL_ID_STUDY_REMINDERS,
                "Study Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminders for scheduled study sessions"
                enableVibration(true)
                enableLights(true)
                setShowBadge(true)
            }
            
            // Flashcard Review Channel - High Priority
            val flashcardChannel = NotificationChannel(
                CHANNEL_ID_FLASHCARD_REVIEW,
                "Flashcard Reviews",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminders to review due flashcards"
                enableVibration(true)
                enableLights(true)
                setShowBadge(true)
            }
            
            // Daily Goals Channel - Default Priority
            val goalsChannel = NotificationChannel(
                CHANNEL_ID_DAILY_GOALS,
                "Daily Goals",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Daily study goal reminders"
                enableVibration(false)
                setShowBadge(true)
            }
            
            notificationManager.createNotificationChannel(studyChannel)
            notificationManager.createNotificationChannel(flashcardChannel)
            notificationManager.createNotificationChannel(goalsChannel)
        }
    }
    
    /**
     * Show a study reminder notification
     */
    fun showStudyReminder(
        context: Context,
        title: String,
        message: String,
        notificationId: Int = NOTIFICATION_ID_STUDY_REMINDER
    ) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_type", "study_reminder")
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID_STUDY_REMINDERS)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Replace with your app icon
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .build()
        
        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }
    
    /**
     * Show a flashcard review reminder notification
     */
    fun showFlashcardReview(
        context: Context,
        deckName: String,
        cardCount: Int,
        deckId: String,
        notificationId: Int = NOTIFICATION_ID_FLASHCARD_REVIEW
    ) {
        val title = "Time to Review Flashcards!"
        val message = "$cardCount cards in \"$deckName\" are due for review"
        
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_type", "flashcard_review")
            putExtra("deck_name", deckName)
            putExtra("deck_id", deckId)
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID_FLASHCARD_REVIEW)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .build()
        
        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }
    
    /**
     * Show a daily goal reminder notification
     */
    fun showDailyGoalReminder(
        context: Context,
        goalProgress: String,
        notificationId: Int = NOTIFICATION_ID_DAILY_GOAL
    ) {
        val title = "Daily Study Goal"
        val message = goalProgress
        
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("notification_type", "daily_goal")
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(context, CHANNEL_ID_DAILY_GOALS)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()
        
        NotificationManagerCompat.from(context).notify(notificationId, notification)
    }
    
    /**
     * Cancel a specific notification
     */
    fun cancelNotification(context: Context, notificationId: Int) {
        NotificationManagerCompat.from(context).cancel(notificationId)
    }
    
    /**
     * Cancel all notifications
     */
    fun cancelAllNotifications(context: Context) {
        NotificationManagerCompat.from(context).cancelAll()
    }
}
