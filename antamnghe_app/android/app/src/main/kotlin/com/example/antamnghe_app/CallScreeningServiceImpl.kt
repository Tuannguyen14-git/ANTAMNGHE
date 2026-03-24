package com.example.antamnghe_app

import android.telecom.CallScreeningService
import android.telecom.Call.Details
import android.telecom.CallScreeningService.CallResponse
import android.util.Log

class CallScreeningServiceImpl : CallScreeningService() {
    companion object {
        // Simple in-memory sets for prototype/demo. Will be updated from Flutter via MethodChannel.
        val spamSet: MutableSet<String> = mutableSetOf()
        val vipSet: MutableSet<String> = mutableSetOf()
    }

    override fun onScreenCall(callDetails: Details) {
        try {
            val handle = callDetails.handle
            val number = handle?.schemeSpecificPart ?: ""
            Log.i("CallScreening", "Incoming call from: $number")

            val builder = CallResponse.Builder()

            if (number.isNotEmpty() && spamSet.contains(number)) {
                // Block spam: disallow and skip notifications/logs
                val response = builder.setDisallowCall(true)
                    .setRejectCall(true)
                    .setSkipCallLog(true)
                    .setSkipNotification(true)
                    .build()
                respondToCall(callDetails, response)
                Log.i("CallScreening", "Blocked spam number: $number")
                return
            }

            if (number.isNotEmpty() && vipSet.contains(number)) {
                // Allow VIP: do not disallow
                val response = builder.setDisallowCall(false).build()
                respondToCall(callDetails, response)
                Log.i("CallScreening", "Allowed VIP number: $number")
                return
            }

            // Default behavior for unknown numbers: silence incoming call (do not reject)
            val response = builder.setDisallowCall(false)
                .setSilenceCall(true)
                .build()
            respondToCall(callDetails, response)
            Log.i("CallScreening", "Silenced unknown number: $number")
        } catch (ex: Exception) {
            Log.e("CallScreening", "Error screening call: ${ex.message}")
            // Fallback: allow call
            val response = CallResponse.Builder().setDisallowCall(false).build()
            respondToCall(callDetails, response)
        }
    }
}
