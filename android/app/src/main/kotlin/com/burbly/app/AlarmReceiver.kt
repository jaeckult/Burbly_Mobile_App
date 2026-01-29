package com.burbly.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receives alarm broadcasts and triggers notifications.
 * This works even if the app is killed or device is rebooted.
 */
class AlarmReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "AlarmReceiver"
        
        // Intent extras keys
        const val EXTRA_NOTIFICATION_TYPE = "notification_type"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_MESSAGE = "message"
        const val EXTRA_DECK_NAME = "deck_name"
        const val EXTRA_CARD_COUNT = "card_count"
        const val EXTRA_DECK_ID = "deck_id"
        
        // Notification types
        const val TYPE_STUDY_REMINDER = "study_reminder"
        const val TYPE_FLASHCARD_REVIEW = "flashcard_review"
        const val TYPE_DAILY_GOAL = "daily_goal"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Alarm received: ${intent.action}")
        
        try {
            val notificationType = intent.getStringExtra(EXTRA_NOTIFICATION_TYPE) ?: TYPE_STUDY_REMINDER
            val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, NotificationHelper.NOTIFICATION_ID_STUDY_REMINDER)
            val title = intent.getStringExtra(EXTRA_TITLE) ?: "Study Reminder"
            val message = intent.getStringExtra(EXTRA_MESSAGE) ?: "Time to study!"
            
            when (notificationType) {
                TYPE_STUDY_REMINDER -> {
                    NotificationHelper.showStudyReminder(
                        context = context,
                        title = title,
                        message = message,
                        notificationId = notificationId
                    )
                }
                
                TYPE_FLASHCARD_REVIEW -> {
                    val deckName = intent.getStringExtra(EXTRA_DECK_NAME) ?: "Your Deck"
                    val cardCount = intent.getIntExtra(EXTRA_CARD_COUNT, 0)
                    val deckId = intent.getStringExtra(EXTRA_DECK_ID) ?: ""
                    
                    NotificationHelper.showFlashcardReview(
                        context = context,
                        deckName = deckName,
                        cardCount = cardCount,
                        deckId = deckId,
                        notificationId = notificationId
                    )
                }
                
                TYPE_DAILY_GOAL -> {
                    NotificationHelper.showDailyGoalReminder(
                        context = context,
                        goalProgress = message,
                        notificationId = notificationId
                    )
                }
                
                else -> {
                    Log.w(TAG, "Unknown notification type: $notificationType")
                    NotificationHelper.showStudyReminder(context, title, message, notificationId)
                }
            }
            
            Log.d(TAG, "Notification shown successfully: $notificationType")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error showing notification", e)
        }
    }
}
