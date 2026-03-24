package com.example.antamnghe_app

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class ScreeningPreferencesTest {
    private lateinit var context: Context

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        context.getSharedPreferences("screening_prefs", Context.MODE_PRIVATE).edit().clear().commit()
    }

    @Test
    fun repeatedUnknownCallOnlyPassesOnSecondAttemptWithinWindow() {
        val firstAttempt = ScreeningPreferences.registerRepeatedUnknownCall(
            context,
            "+84901234567",
            5 * 60 * 1000L,
        )
        val secondAttempt = ScreeningPreferences.registerRepeatedUnknownCall(
            context,
            "+84901234567",
            5 * 60 * 1000L,
        )

        assertFalse(firstAttempt)
        assertTrue(secondAttempt)
    }

    @Test
    fun temporaryAllowExpiresAfterConfiguredWindow() {
        ScreeningPreferences.allowTemporaryNumber(context, "+84908887766", 10L)

        assertTrue(ScreeningPreferences.isTemporaryAllowed(context, "+84908887766"))

        Thread.sleep(20L)

        assertFalse(ScreeningPreferences.isTemporaryAllowed(context, "+84908887766"))
    }

    @Test
    fun focusModeCanBeEnabledAndCleared() {
        ScreeningPreferences.enableFocusMode(context, 1)

        assertTrue(ScreeningPreferences.isFocusModeActive(context))

        ScreeningPreferences.clearFocusMode(context)

        assertFalse(ScreeningPreferences.isFocusModeActive(context))
    }
}