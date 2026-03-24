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
class EmergencySmsReceiverTest {
    private lateinit var context: Context

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        context.getSharedPreferences("screening_prefs", Context.MODE_PRIVATE).edit().clear().commit()
    }

    @Test
    fun matchingEmergencyKeywordTemporarilyAllowsSender() {
        val receiver = EmergencySmsReceiver()
        ScreeningPreferences.setEmergencyKeywords(context, listOf("cap cuu", "goi lai gap"))

        val matched = receiver.handleMessage(
            context,
            "+84901112233",
            "Nha co viec cap cuu, goi lai gap",
        )

        assertTrue(matched)
        assertTrue(ScreeningPreferences.isTemporaryAllowed(context, "+84901112233"))
    }

    @Test
    fun nonMatchingSmsDoesNotWhitelistSender() {
        val receiver = EmergencySmsReceiver()
        ScreeningPreferences.setEmergencyKeywords(context, listOf("cap cuu"))

        val matched = receiver.handleMessage(
            context,
            "+84904445566",
            "Chi muon hoi tham thoi",
        )

        assertFalse(matched)
        assertFalse(ScreeningPreferences.isTemporaryAllowed(context, "+84904445566"))
    }
}