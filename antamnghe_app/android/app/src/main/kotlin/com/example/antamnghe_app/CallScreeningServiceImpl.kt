package com.example.antamnghe_app

import android.telecom.CallScreeningService
import android.telecom.Call.Details
import android.telecom.CallScreeningService.CallResponse
import android.util.Log

class CallScreeningServiceImpl : CallScreeningService() {
    companion object {
        private const val TAG = "CallScreening"
        private const val REPEATED_CALL_WINDOW_MS = 5 * 60 * 1000L
    }

    override fun onScreenCall(callDetails: Details) {
        try {
            val handle = callDetails.handle
            val number = ScreeningPreferences.normalizeNumber(handle?.schemeSpecificPart ?: "")
            val spamSet = ScreeningPreferences.getSpamList(applicationContext)
            val vipSet = ScreeningPreferences.getVipList(applicationContext)
            Log.i(TAG, "Incoming call from: $number")

            val builder = CallResponse.Builder()

            if (number.isNotEmpty() && spamSet.contains(number)) {
                val response = builder.setDisallowCall(true)
                    .setRejectCall(true)
                    .setSkipCallLog(true)
                    .setSkipNotification(true)
                    .build()
                respondToCall(callDetails, response)
                Log.i(TAG, "Blocked spam number: $number")
                return
            }

            if (number.isNotEmpty() && vipSet.contains(number)) {
                val response = builder.setDisallowCall(false).build()
                respondToCall(callDetails, response)
                Log.i(TAG, "Allowed VIP number: $number")
                return
            }

            if (number.isNotEmpty() && ScreeningPreferences.isTemporaryAllowed(applicationContext, number)) {
                val response = builder.setDisallowCall(false).build()
                respondToCall(callDetails, response)
                Log.i(TAG, "Allowed temporary emergency number: $number")
                return
            }

            if (!ScreeningPreferences.isFocusModeActive(applicationContext)) {
                val response = builder.setDisallowCall(false).build()
                respondToCall(callDetails, response)
                Log.i(TAG, "Allowed call because focus mode is off: $number")
                return
            }

            if (number.isNotEmpty() && ScreeningPreferences.registerRepeatedUnknownCall(
                    applicationContext,
                    number,
                    REPEATED_CALL_WINDOW_MS,
                )
            ) {
                val response = builder.setDisallowCall(false).build()
                respondToCall(callDetails, response)
                Log.i(TAG, "Allowed repeated unknown call: $number")
                return
            }

            val response = builder.setDisallowCall(false)
                .setSilenceCall(true)
                .build()
            respondToCall(callDetails, response)
            Log.i(TAG, "Silenced unknown number during focus mode: $number")
        } catch (ex: Exception) {
            Log.e(TAG, "Error screening call: ${ex.message}")
            val response = CallResponse.Builder().setDisallowCall(false).build()
            respondToCall(callDetails, response)
        }
    }
}
