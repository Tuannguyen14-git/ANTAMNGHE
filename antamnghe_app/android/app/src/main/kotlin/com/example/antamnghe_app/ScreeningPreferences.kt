package com.example.antamnghe_app

import android.content.Context
import org.json.JSONObject

object ScreeningPreferences {
    private const val PREFS_NAME = "screening_prefs"
    private const val SPAM_NUMBERS_KEY = "spam_numbers"
    private const val VIP_NUMBERS_KEY = "vip_numbers"
    private const val EMERGENCY_KEYWORDS_KEY = "emergency_keywords"
    private const val FOCUS_UNTIL_KEY = "focus_until_ms"
    private const val UNKNOWN_CALLS_KEY = "unknown_calls"
    private const val TEMP_ALLOWED_KEY = "temp_allowed_numbers"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun normalizeNumber(number: String): String {
        return number.trim().filter { it.isDigit() || it == '+' }
    }

    fun setSpamList(context: Context, numbers: List<String>) {
        prefs(context).edit()
            .putStringSet(SPAM_NUMBERS_KEY, numbers.map(::normalizeNumber).filter { it.isNotEmpty() }.toSet())
            .apply()
    }

    fun getSpamList(context: Context): Set<String> {
        return prefs(context).getStringSet(SPAM_NUMBERS_KEY, emptySet()) ?: emptySet()
    }

    fun setVipList(context: Context, numbers: List<String>) {
        prefs(context).edit()
            .putStringSet(VIP_NUMBERS_KEY, numbers.map(::normalizeNumber).filter { it.isNotEmpty() }.toSet())
            .apply()
    }

    fun getVipList(context: Context): Set<String> {
        return prefs(context).getStringSet(VIP_NUMBERS_KEY, emptySet()) ?: emptySet()
    }

    fun setEmergencyKeywords(context: Context, keywords: List<String>) {
        prefs(context).edit()
            .putStringSet(
                EMERGENCY_KEYWORDS_KEY,
                keywords.map { it.trim().lowercase() }.filter { it.isNotEmpty() }.toSet(),
            )
            .apply()
    }

    fun getEmergencyKeywords(context: Context): Set<String> {
        return prefs(context).getStringSet(EMERGENCY_KEYWORDS_KEY, emptySet()) ?: emptySet()
    }

    fun enableFocusMode(context: Context, durationMinutes: Int) {
        val until = System.currentTimeMillis() + durationMinutes.coerceAtLeast(1) * 60_000L
        prefs(context).edit().putLong(FOCUS_UNTIL_KEY, until).apply()
    }

    fun clearFocusMode(context: Context) {
        prefs(context).edit().remove(FOCUS_UNTIL_KEY).apply()
    }

    fun getFocusUntilMillis(context: Context): Long {
        return prefs(context).getLong(FOCUS_UNTIL_KEY, 0L)
    }

    fun isFocusModeActive(context: Context): Boolean {
        val until = getFocusUntilMillis(context)
        if (until <= System.currentTimeMillis()) {
            if (until != 0L) {
                clearFocusMode(context)
            }
            return false
        }
        return true
    }

    fun allowTemporaryNumber(context: Context, number: String, durationMs: Long) {
        val normalized = normalizeNumber(number)
        if (normalized.isEmpty()) return
        val map = readLongMap(context, TEMP_ALLOWED_KEY)
        map[normalized] = System.currentTimeMillis() + durationMs
        writeLongMap(context, TEMP_ALLOWED_KEY, map)
    }

    fun isTemporaryAllowed(context: Context, number: String): Boolean {
        val normalized = normalizeNumber(number)
        if (normalized.isEmpty()) return false
        val now = System.currentTimeMillis()
        val map = readLongMap(context, TEMP_ALLOWED_KEY)
        val expiresAt = map[normalized]
        val isAllowed = expiresAt != null && expiresAt > now
        pruneExpiredEntries(map, now)
        writeLongMap(context, TEMP_ALLOWED_KEY, map)
        return isAllowed
    }

    fun registerRepeatedUnknownCall(context: Context, number: String, windowMs: Long): Boolean {
        val normalized = normalizeNumber(number)
        if (normalized.isEmpty()) return false
        val now = System.currentTimeMillis()
        val map = readLongMap(context, UNKNOWN_CALLS_KEY)
        val lastSeen = map[normalized]
        map[normalized] = now
        pruneExpiredEntries(map, now - windowMs)
        writeLongMap(context, UNKNOWN_CALLS_KEY, map)
        return lastSeen != null && now - lastSeen <= windowMs
    }

    private fun pruneExpiredEntries(map: MutableMap<String, Long>, threshold: Long) {
        val iterator = map.entries.iterator()
        while (iterator.hasNext()) {
            if (iterator.next().value <= threshold) {
                iterator.remove()
            }
        }
    }

    private fun readLongMap(context: Context, key: String): MutableMap<String, Long> {
        val raw = prefs(context).getString(key, null) ?: return mutableMapOf()
        return try {
            val json = JSONObject(raw)
            val result = mutableMapOf<String, Long>()
            val keys = json.keys()
            while (keys.hasNext()) {
                val entryKey = keys.next()
                result[entryKey] = json.optLong(entryKey)
            }
            result
        } catch (_: Exception) {
            mutableMapOf()
        }
    }

    private fun writeLongMap(context: Context, key: String, map: Map<String, Long>) {
        val json = JSONObject()
        map.forEach { (entryKey, value) ->
            json.put(entryKey, value)
        }
        prefs(context).edit().putString(key, json.toString()).apply()
    }
}
