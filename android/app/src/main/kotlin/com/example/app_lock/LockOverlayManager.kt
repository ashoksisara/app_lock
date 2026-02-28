package com.example.app_lock

import android.animation.ObjectAnimator
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.GridLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import java.security.MessageDigest

class LockOverlayManager(private val context: Context) {

    companion object {
        private const val TAG = "LockOverlayManager"
    }

    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val handler = Handler(Looper.getMainLooper())

    private var overlayView: FrameLayout? = null
    private var packageNameExtra = ""
    private var profiles: List<ProfileData> = emptyList()
    private var selectedProfile: ProfileData? = null
    private var enteredPin = ""
    private var wrongAttempts = 0
    private var isLockedOut = false
    private val pinDotViews = mutableListOf<View>()
    private var errorTextView: TextView? = null

    private var surfaceColor = Color.WHITE
    private var onSurfaceColor = Color.BLACK
    private var primaryColor = Color.parseColor("#6750A4")
    private var errorColor = Color.parseColor("#B3261E")
    private var outlineColor = Color.parseColor("#79747E")
    private var surfaceVariantColor = Color.parseColor("#E7E0EC")

    val isShowing: Boolean get() = overlayView != null

    fun show(packageName: String, profileList: List<ProfileData>) {
        if (overlayView != null) return

        packageNameExtra = packageName
        profiles = profileList
        selectedProfile = null
        enteredPin = ""
        wrongAttempts = 0
        isLockedOut = false
        pinDotViews.clear()
        errorTextView = null

        resolveColors()

        val root = FrameLayout(context).apply {
            setBackgroundColor(surfaceColor)
        }

        overlayView = root

        if (profiles.size > 1) {
            showProfilePicker(root)
        } else if (profiles.isNotEmpty()) {
            selectedProfile = profiles[0]
            showPinScreen(root)
        } else {
            return
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            PixelFormat.OPAQUE
        )
        params.gravity = Gravity.CENTER

        try {
            windowManager.addView(root, params)
            Log.d(TAG, "Overlay shown for $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add overlay", e)
            overlayView = null
        }
    }

    fun dismiss() {
        val view = overlayView ?: return
        try {
            windowManager.removeView(view)
        } catch (_: Exception) {}
        overlayView = null
        pinDotViews.clear()
        errorTextView = null
        Log.d(TAG, "Overlay dismissed")
    }

    private fun resolveColors() {
        val config = context.resources.configuration
        val nightMode = config.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK
        val isDark = nightMode == android.content.res.Configuration.UI_MODE_NIGHT_YES
        if (isDark) {
            surfaceColor = Color.parseColor("#1C1B1F")
            onSurfaceColor = Color.parseColor("#E6E1E5")
            primaryColor = Color.parseColor("#D0BCFF")
            errorColor = Color.parseColor("#F2B8B5")
            outlineColor = Color.parseColor("#938F99")
            surfaceVariantColor = Color.parseColor("#49454F")
        } else {
            surfaceColor = Color.WHITE
            onSurfaceColor = Color.BLACK
            primaryColor = Color.parseColor("#6750A4")
            errorColor = Color.parseColor("#B3261E")
            outlineColor = Color.parseColor("#79747E")
            surfaceVariantColor = Color.parseColor("#E7E0EC")
        }
    }

    private fun goHome() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(homeIntent)
    }

    // --- Profile Picker ---

    private fun showProfilePicker(root: FrameLayout) {
        root.removeAllViews()

        val scrollView = ScrollView(context)
        val layout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(24), dp(48), dp(24), dp(24))
        }

        val lockIcon = TextView(context).apply {
            text = "\uD83D\uDD12"
            textSize = 48f
            gravity = Gravity.CENTER
        }
        layout.addView(lockIcon, lp(true).apply { bottomMargin = dp(16) })

        val title = TextView(context).apply {
            text = "App is Locked"
            textSize = 24f
            setTextColor(onSurfaceColor)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
        }
        layout.addView(title, lp(true).apply { bottomMargin = dp(8) })

        val subtitle = TextView(context).apply {
            text = "Select your profile to unlock"
            textSize = 14f
            setTextColor(outlineColor)
            gravity = Gravity.CENTER
        }
        layout.addView(subtitle, lp(true).apply { bottomMargin = dp(32) })

        for (profile in profiles) {
            layout.addView(createProfileCard(profile), lp(true).apply { bottomMargin = dp(12) })
        }

        scrollView.addView(layout)
        root.addView(scrollView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))
    }

    private fun createProfileCard(profile: ProfileData): LinearLayout {
        val bg = GradientDrawable().apply {
            cornerRadius = dp(16).toFloat()
            setColor(surfaceVariantColor)
        }

        return LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(16), dp(16), dp(16), dp(16))
            background = bg
            isClickable = true
            isFocusable = true

            addView(TextView(context).apply {
                text = profile.emoji
                textSize = 32f
            }, LinearLayout.LayoutParams(dp(48), dp(48)).apply { marginEnd = dp(16) })

            addView(TextView(context).apply {
                text = profile.name
                textSize = 18f
                setTextColor(onSurfaceColor)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            }, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f))

            addView(TextView(context).apply {
                text = "›"
                textSize = 24f
                setTextColor(outlineColor)
            })

            setOnClickListener {
                selectedProfile = profile
                enteredPin = ""
                wrongAttempts = 0
                isLockedOut = false
                pinDotViews.clear()
                errorTextView = null
                overlayView?.let { showPinScreen(it) }
            }
        }
    }

    // --- PIN Screen ---

    private fun showPinScreen(root: FrameLayout) {
        root.removeAllViews()
        enteredPin = ""
        pinDotViews.clear()

        val profile = selectedProfile ?: return

        val layout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(24), dp(48), dp(24), dp(24))
        }

        layout.addView(TextView(context).apply {
            text = profile.emoji
            textSize = 48f
            gravity = Gravity.CENTER
        }, lp(true).apply { bottomMargin = dp(12) })

        layout.addView(TextView(context).apply {
            text = profile.name
            textSize = 20f
            setTextColor(onSurfaceColor)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            gravity = Gravity.CENTER
        }, lp(true).apply { bottomMargin = dp(4) })

        layout.addView(TextView(context).apply {
            text = "Enter PIN to unlock"
            textSize = 14f
            setTextColor(outlineColor)
            gravity = Gravity.CENTER
        }, lp(true).apply { bottomMargin = dp(32) })

        val dotsRow = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
        }
        for (i in 0 until 4) {
            val dot = View(context).apply {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setStroke(dp(2), outlineColor)
                    setSize(dp(16), dp(16))
                }
            }
            pinDotViews.add(dot)
            dotsRow.addView(dot, LinearLayout.LayoutParams(dp(16), dp(16)).apply {
                marginStart = if (i == 0) 0 else dp(16)
            })
        }
        layout.addView(dotsRow, lp(true).apply { bottomMargin = dp(12) })

        errorTextView = TextView(context).apply {
            text = ""
            textSize = 13f
            setTextColor(errorColor)
            gravity = Gravity.CENTER
            visibility = View.INVISIBLE
        }
        layout.addView(errorTextView, lp(true).apply { bottomMargin = dp(24) })

        layout.addView(buildNumberPad(), lp(false))

        if (profiles.size > 1) {
            layout.addView(TextView(context).apply {
                text = "Switch Profile"
                textSize = 14f
                setTextColor(primaryColor)
                gravity = Gravity.CENTER
                setPadding(dp(16), dp(12), dp(16), dp(12))
                setOnClickListener { overlayView?.let { showProfilePicker(it) } }
            }, lp(true).apply { topMargin = dp(16) })
        }

        val scrollView = ScrollView(context).apply { isFillViewport = true }
        scrollView.addView(layout)
        root.addView(scrollView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))
    }

    private fun buildNumberPad(): GridLayout {
        val grid = GridLayout(context).apply {
            columnCount = 3
            rowCount = 4
            useDefaultMargins = false
        }
        val keys = listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "⌫", "0", "✕")
        for ((index, key) in keys.withIndex()) {
            val params = GridLayout.LayoutParams().apply {
                width = dp(72)
                height = dp(72)
                rowSpec = GridLayout.spec(index / 3)
                columnSpec = GridLayout.spec(index % 3)
                setMargins(dp(8), dp(8), dp(8), dp(8))
            }
            grid.addView(createPadButton(key), params)
        }
        return grid
    }

    private fun createPadButton(key: String): TextView {
        return TextView(context).apply {
            text = key
            textSize = if (key == "⌫" || key == "✕") 20f else 24f
            setTextColor(onSurfaceColor)
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(surfaceVariantColor)
            }
            isClickable = true
            isFocusable = true
            setOnClickListener {
                if (isLockedOut) return@setOnClickListener
                when (key) {
                    "⌫" -> onBackspace()
                    "✕" -> goHome()
                    else -> onDigit(key)
                }
            }
        }
    }

    private fun onDigit(digit: String) {
        if (enteredPin.length >= 4) return
        enteredPin += digit
        updatePinDots()
        if (enteredPin.length == 4) verifyPin()
    }

    private fun onBackspace() {
        if (enteredPin.isEmpty()) return
        enteredPin = enteredPin.dropLast(1)
        updatePinDots()
        errorTextView?.visibility = View.INVISIBLE
    }

    private fun updatePinDots(isError: Boolean = false) {
        for (i in pinDotViews.indices) {
            pinDotViews[i].background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                if (i < enteredPin.length) {
                    setColor(if (isError) errorColor else primaryColor)
                } else {
                    setColor(Color.TRANSPARENT)
                    setStroke(dp(2), if (isError) errorColor else outlineColor)
                }
                setSize(dp(16), dp(16))
            }
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
            LocalBroadcastManager.getInstance(context).sendBroadcast(intent)
            dismiss()
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
                errorTextView?.visibility = View.INVISIBLE
            }, 30_000)
        } else {
            showError("Wrong PIN. ${5 - wrongAttempts} attempts remaining.")
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

    private fun hashPin(pin: String): String {
        val bytes = pin.toByteArray(Charsets.UTF_8)
        val digest = MessageDigest.getInstance("SHA-256").digest(bytes)
        return digest.joinToString("") { "%02x".format(it) }
    }

    private fun dp(value: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            value.toFloat(),
            context.resources.displayMetrics
        ).toInt()
    }

    private fun lp(matchParent: Boolean): LinearLayout.LayoutParams {
        val w = if (matchParent) LinearLayout.LayoutParams.MATCH_PARENT
                else LinearLayout.LayoutParams.WRAP_CONTENT
        return LinearLayout.LayoutParams(w, LinearLayout.LayoutParams.WRAP_CONTENT)
    }
}
