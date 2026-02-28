package com.example.app_lock

import android.animation.ObjectAnimator
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.GridLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import org.json.JSONArray
import java.security.MessageDigest

class LockActivity : ComponentActivity() {

    private var packageNameExtra: String = ""
    private var profiles: List<ProfileData> = emptyList()
    private var selectedProfile: ProfileData? = null
    private var enteredPin = ""
    private var wrongAttempts = 0
    private var isLockedOut = false

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var rootContainer: FrameLayout
    private val pinDotViews = mutableListOf<View>()
    private var errorTextView: TextView? = null

    private var surfaceColor = Color.WHITE
    private var onSurfaceColor = Color.BLACK
    private var primaryColor = Color.parseColor("#6750A4")
    private var errorColor = Color.parseColor("#B3261E")
    private var outlineColor = Color.parseColor("#79747E")
    private var surfaceVariantColor = Color.parseColor("#E7E0EC")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        @Suppress("DEPRECATION")
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )

        resolveThemeColors()

        packageNameExtra = intent.getStringExtra(AppLockAccessibilityService.EXTRA_PACKAGE_NAME) ?: ""
        val profilesJson = intent.getStringExtra("profiles_json") ?: "[]"
        profiles = parseProfiles(profilesJson)

        rootContainer = FrameLayout(this).apply {
            setBackgroundColor(surfaceColor)
        }
        setContentView(rootContainer)

        if (profiles.size > 1) {
            showProfilePicker()
        } else if (profiles.size == 1) {
            selectedProfile = profiles[0]
            showPinScreen()
        } else {
            finish()
        }
    }

    private fun resolveThemeColors() {
        val tv = TypedValue()
        if (theme.resolveAttribute(android.R.attr.colorBackground, tv, true)) {
            surfaceColor = tv.data
        }
        if (theme.resolveAttribute(android.R.attr.textColorPrimary, tv, true)) {
            onSurfaceColor = tv.data
        }

        val isDark = Color.luminance(surfaceColor) < 0.5f
        if (isDark) {
            primaryColor = Color.parseColor("#D0BCFF")
            errorColor = Color.parseColor("#F2B8B5")
            outlineColor = Color.parseColor("#938F99")
            surfaceVariantColor = Color.parseColor("#49454F")
        }
    }

    // --- Profile Picker ---

    private fun showProfilePicker() {
        rootContainer.removeAllViews()

        val scrollView = ScrollView(this)
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(24), dp(48), dp(24), dp(24))
        }

        val lockIcon = TextView(this).apply {
            text = "\uD83D\uDD12"
            textSize = 48f
            gravity = Gravity.CENTER
        }
        layout.addView(lockIcon, linearParams(matchParent = true).apply {
            bottomMargin = dp(16)
        })

        val title = TextView(this).apply {
            text = "App is Locked"
            textSize = 24f
            setTextColor(onSurfaceColor)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
        }
        layout.addView(title, linearParams(matchParent = true).apply {
            bottomMargin = dp(8)
        })

        val subtitle = TextView(this).apply {
            text = "Select your profile to unlock"
            textSize = 14f
            setTextColor(outlineColor)
            gravity = Gravity.CENTER
        }
        layout.addView(subtitle, linearParams(matchParent = true).apply {
            bottomMargin = dp(32)
        })

        for (profile in profiles) {
            val card = createProfileCard(profile)
            layout.addView(card, linearParams(matchParent = true).apply {
                bottomMargin = dp(12)
            })
        }

        scrollView.addView(layout)
        rootContainer.addView(scrollView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))
    }

    private fun createProfileCard(profile: ProfileData): LinearLayout {
        val bg = GradientDrawable().apply {
            cornerRadius = dp(16).toFloat()
            setColor(surfaceVariantColor)
        }

        return LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(16), dp(16), dp(16), dp(16))
            background = bg
            isClickable = true
            isFocusable = true

            val emoji = TextView(this@LockActivity).apply {
                text = profile.emoji
                textSize = 32f
            }
            addView(emoji, LinearLayout.LayoutParams(dp(48), dp(48)).apply {
                marginEnd = dp(16)
            })

            val name = TextView(this@LockActivity).apply {
                text = profile.name
                textSize = 18f
                setTextColor(onSurfaceColor)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            }
            addView(name, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))

            val arrow = TextView(this@LockActivity).apply {
                text = "›"
                textSize = 24f
                setTextColor(outlineColor)
            }
            addView(arrow)

            setOnClickListener {
                selectedProfile = profile
                showPinScreen()
            }
        }
    }

    // --- PIN Screen ---

    private fun showPinScreen() {
        rootContainer.removeAllViews()
        enteredPin = ""
        pinDotViews.clear()

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(24), dp(48), dp(24), dp(24))
        }

        val profile = selectedProfile ?: return

        val emojiView = TextView(this).apply {
            text = profile.emoji
            textSize = 48f
            gravity = Gravity.CENTER
        }
        layout.addView(emojiView, linearParams(matchParent = true).apply {
            bottomMargin = dp(12)
        })

        val nameView = TextView(this).apply {
            text = profile.name
            textSize = 20f
            setTextColor(onSurfaceColor)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
        }
        layout.addView(nameView, linearParams(matchParent = true).apply {
            bottomMargin = dp(4)
        })

        val hintView = TextView(this).apply {
            text = "Enter PIN to unlock"
            textSize = 14f
            setTextColor(outlineColor)
            gravity = Gravity.CENTER
        }
        layout.addView(hintView, linearParams(matchParent = true).apply {
            bottomMargin = dp(32)
        })

        val dotsRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
        }
        for (i in 0 until 4) {
            val dot = View(this).apply {
                val bg = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setStroke(dp(2), outlineColor)
                    setSize(dp(16), dp(16))
                }
                background = bg
            }
            pinDotViews.add(dot)
            dotsRow.addView(dot, LinearLayout.LayoutParams(dp(16), dp(16)).apply {
                marginStart = if (i == 0) 0 else dp(16)
            })
        }
        layout.addView(dotsRow, linearParams(matchParent = true).apply {
            bottomMargin = dp(12)
        })

        errorTextView = TextView(this).apply {
            text = ""
            textSize = 13f
            setTextColor(errorColor)
            gravity = Gravity.CENTER
            visibility = View.INVISIBLE
        }
        layout.addView(errorTextView, linearParams(matchParent = true).apply {
            bottomMargin = dp(24)
        })

        val numPad = buildNumberPad()
        layout.addView(numPad, linearParams(matchParent = false))

        if (profiles.size > 1) {
            val backBtn = TextView(this).apply {
                text = "Switch Profile"
                textSize = 14f
                setTextColor(primaryColor)
                gravity = Gravity.CENTER
                setPadding(dp(16), dp(12), dp(16), dp(12))
                setOnClickListener { showProfilePicker() }
            }
            layout.addView(backBtn, linearParams(matchParent = true).apply {
                topMargin = dp(16)
            })
        }

        val scrollView = ScrollView(this).apply {
            isFillViewport = true
        }
        scrollView.addView(layout)
        rootContainer.addView(scrollView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))
    }

    private fun buildNumberPad(): GridLayout {
        val grid = GridLayout(this).apply {
            columnCount = 3
            rowCount = 4
            useDefaultMargins = false
        }

        val keys = listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "⌫", "0", "✕")

        for ((index, key) in keys.withIndex()) {
            val row = index / 3
            val col = index % 3
            val button = createPadButton(key)
            val params = GridLayout.LayoutParams().apply {
                width = dp(72)
                height = dp(72)
                rowSpec = GridLayout.spec(row)
                columnSpec = GridLayout.spec(col)
                setMargins(dp(8), dp(8), dp(8), dp(8))
            }
            grid.addView(button, params)
        }

        return grid
    }

    private fun createPadButton(key: String): TextView {
        val bg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(surfaceVariantColor)
        }

        return TextView(this).apply {
            text = key
            textSize = if (key == "⌫" || key == "✕") 20f else 24f
            setTextColor(onSurfaceColor)
            gravity = Gravity.CENTER
            background = bg
            isClickable = true
            isFocusable = true

            setOnClickListener {
                if (isLockedOut) return@setOnClickListener
                when (key) {
                    "⌫" -> onBackspace()
                    "✕" -> onCancel()
                    else -> onDigit(key)
                }
            }
        }
    }

    private fun onDigit(digit: String) {
        if (enteredPin.length >= 4) return
        enteredPin += digit
        updatePinDots()
        if (enteredPin.length == 4) {
            verifyPin()
        }
    }

    private fun onBackspace() {
        if (enteredPin.isEmpty()) return
        enteredPin = enteredPin.dropLast(1)
        updatePinDots()
        hideError()
    }

    private fun onCancel() {
        moveTaskToBack(true)
    }

    private fun updatePinDots(isError: Boolean = false) {
        for (i in pinDotViews.indices) {
            val dot = pinDotViews[i]
            val bg = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                if (i < enteredPin.length) {
                    setColor(if (isError) errorColor else primaryColor)
                } else {
                    setColor(Color.TRANSPARENT)
                    setStroke(dp(2), if (isError) errorColor else outlineColor)
                }
                setSize(dp(16), dp(16))
            }
            dot.background = bg
        }
    }

    private fun verifyPin() {
        val profile = selectedProfile ?: return
        val hashed = hashPin(enteredPin)

        if (hashed == profile.hashedPin) {
            wrongAttempts = 0
            val intent = Intent(AppLockAccessibilityService.ACTION_UNLOCK_SUCCESS).apply {
                putExtra(AppLockAccessibilityService.EXTRA_PACKAGE_NAME, packageNameExtra)
            }
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
            finish()
        } else {
            wrongAttempts++
            showWrongPinFeedback()
        }
    }

    private fun showWrongPinFeedback() {
        updatePinDots(isError = true)

        val dotsParent = pinDotViews.firstOrNull()?.parent as? View
        if (dotsParent != null) {
            ObjectAnimator.ofFloat(dotsParent, "translationX", 0f, -10f, 10f, -10f, 10f, -5f, 5f, 0f).apply {
                duration = 400
                start()
            }
        }

        if (wrongAttempts >= 5) {
            showError("Too many attempts. Wait 30 seconds.")
            isLockedOut = true
            handler.postDelayed({
                isLockedOut = false
                wrongAttempts = 0
                hideError()
            }, 30_000)
        } else {
            val remaining = 5 - wrongAttempts
            showError("Wrong PIN. $remaining attempts remaining.")
        }

        handler.postDelayed({
            enteredPin = ""
            updatePinDots()
        }, 500)
    }

    private fun showError(message: String) {
        errorTextView?.text = message
        errorTextView?.visibility = View.VISIBLE
    }

    private fun hideError() {
        errorTextView?.visibility = View.INVISIBLE
    }

    private fun hashPin(pin: String): String {
        val bytes = pin.toByteArray(Charsets.UTF_8)
        val digest = MessageDigest.getInstance("SHA-256").digest(bytes)
        return digest.joinToString("") { "%02x".format(it) }
    }

    private fun parseProfiles(json: String): List<ProfileData> {
        val list = mutableListOf<ProfileData>()
        try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                list.add(
                    ProfileData(
                        id = obj.getInt("id"),
                        name = obj.getString("name"),
                        emoji = obj.getString("emoji"),
                        hashedPin = obj.getString("hashedPin")
                    )
                )
            }
        } catch (e: Exception) {
            // If parsing fails, return empty list
        }
        return list
    }

    @Deprecated("Use onBackPressedDispatcher instead")
    override fun onBackPressed() {
        moveTaskToBack(true)
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    // --- Layout helpers ---

    private fun dp(value: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            resources.displayMetrics
        ).toInt()
    }

    private fun linearParams(matchParent: Boolean = false): LinearLayout.LayoutParams {
        val width = if (matchParent) LinearLayout.LayoutParams.MATCH_PARENT
                     else LinearLayout.LayoutParams.WRAP_CONTENT
        return LinearLayout.LayoutParams(width, LinearLayout.LayoutParams.WRAP_CONTENT)
    }
}
