package com.burbly.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Handles device boot and app update events.
 * Reschedules all alarms after device reboot.
 */
class BootReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "BootReceiver"
        private const val PREFS_NAME = "burbly_notification_prefs"
        private const val KEY_NEEDS_RESCHEDULE = "needs_reschedule"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Boot event received: ${intent.action}")
        
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED -> {
                Log.d(TAG, "Device booted - marking alarms for rescheduling")
                markForReschedule(context)
            }
            
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Log.d(TAG, "App updated - marking alarms for rescheduling")
                markForReschedule(context)
            }
        }
    }
    
    /**
     * Mark that alarms need to be rescheduled.
     * The actual rescheduling happens when the app is opened and Flutter engine starts.
     */
    private fun markForReschedule(context: Context) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putBoolean(KEY_NEEDS_RESCHEDULE, true).apply()
            Log.d(TAG, "Marked alarms for rescheduling")
        } catch (e: Exception) {
            Log.e(TAG, "Error marking for reschedule", e)
        }
    }
    
    /**
     * Check if alarms need to be rescheduled and clear the flag.
     * This should be called from Flutter when the app starts.
     */
    fun needsReschedule(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val needs = prefs.getBoolean(KEY_NEEDS_RESCHEDULE, false)
        
        if (needs) {
            // Clear the flag
            prefs.edit().putBoolean(KEY_NEEDS_RESCHEDULE, false).apply()
        }
        
        return needs
    }
}
