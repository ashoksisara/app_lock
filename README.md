# Multi-Profile App Locker -- Android App Lock with Separate PINs per User

Multi-Profile App Locker is an open-source Android app locker built with Flutter and Kotlin that lets two people share one device with complete app privacy. Each user creates their own profile with a separate 4-digit PIN, selects which apps to lock, and a native Kotlin Accessibility Service overlay blocks access until the correct PIN is entered.

Whether you're sharing a phone with a partner, a family member, or a roommate -- Multi-Profile App Locker gives each person their own locked app list, their own PIN, and their own privacy. No root required, no third-party lock engines -- just a native overlay powered by Android's Accessibility Service.

## Key Features

- **Multi-profile app locking** -- two independent profiles on one device, each with its own name, emoji avatar, 4-digit PIN, and locked app list
- **Native Kotlin lock overlay** -- a `TYPE_APPLICATION_OVERLAY` window drawn on top of locked apps with profile picker and PIN pad; falls back to a dedicated `LockActivity` shown on lock screen
- **SHA-256 PIN hashing** -- PINs are never stored in plain text; hashed using the `crypto` package before writing to the database
- **Brute-force protection** -- 5 wrong PIN attempts trigger a 30-second lockout with shake animation feedback
- **Categorized app selection** -- browse all installed apps sorted by category (Social, Google, Entertainment, Other) with real-time search and selection counter
- **Onboarding flow** -- three-page introduction explaining the concept, followed by a step-by-step profile setup (avatar, name, PIN, confirm)
- **Boot persistence** -- a `BootReceiver` restores app lock protection automatically after device restarts
- **Configurable re-lock timing** -- set how long after unlocking an app before it locks again
- **Dark & Light mode** -- Material 3 themed UI and native overlay both respect the device theme
- **Theme color customization** -- pick a Material 3 seed color to personalize the entire app
- **Change PIN flow** -- update your PIN after verifying the current one; no way to bypass without the old PIN
- **Danger zone** -- full profile reset and uninstall protection options gated behind PIN verification
- **Biometric unlock (planned)** -- `local_auth` dependency is included; biometric authentication is declared in settings UI but not yet wired

## Screenshots

<!-- Add screenshots to a screenshots/ folder and uncomment the tables below -->

<!--
| Onboarding | Profile Setup |
|:---:|:---:|
| ![Onboarding flow for multi-profile app locker](screenshots/01_onboarding.png) | ![Create profile with emoji avatar and PIN](screenshots/02_profile_setup.png) |

| Home | App Selection |
|:---:|:---:|
| ![Home screen showing profile cards and service status](screenshots/03_home.png) | ![Select apps to lock by category](screenshots/04_app_selection.png) |

| Lock Overlay | Settings |
|:---:|:---:|
| ![Native PIN lock overlay on locked app](screenshots/05_lock_overlay.png) | ![Settings screen with re-lock timing and theme](screenshots/06_settings.png) |
-->

## How It Works

1. **Create Profiles** -- each user sets up a profile with a name, emoji avatar, and 4-digit PIN (hashed with SHA-256 before storage)
2. **Select Apps** -- browse installed apps by category, search by name, and toggle which apps to lock for that profile
3. **Enable Protection** -- grant Accessibility Service and overlay permissions; the native Kotlin service starts monitoring foreground app changes
4. **Lock Triggered** -- when a locked app is opened, the service checks the SQLite database and draws a full-screen overlay asking for the profile PIN
5. **Unlock** -- enter the correct PIN to dismiss the overlay; a configurable cooldown prevents immediate re-locking
6. **Boot Recovery** -- after a device restart, `BootReceiver` checks SharedPreferences and protection resumes automatically

## Getting Started

### Prerequisites

- Flutter SDK >= 3.11.0
- Android SDK
- A physical Android device (Accessibility Services do not work reliably on emulators)

### Setup

```bash
git clone https://github.com/<your-username>/app_lock.git
cd app_lock
flutter pub get
flutter run
```

### First Run

1. Grant overlay permission (`SYSTEM_ALERT_WINDOW`) when prompted
2. Enable the Accessibility Service in device settings -- the app guides you to the correct screen
3. Complete the onboarding and create your first profile with a 4-digit PIN
4. Select apps to lock, then open one of them to see the lock overlay in action

## Android Permissions

| Permission | Reason |
|---|---|
| `SYSTEM_ALERT_WINDOW` | Draw the PIN lock overlay on top of locked apps |
| `RECEIVE_BOOT_COMPLETED` | Restart protection automatically after device reboot |
| Accessibility Service | Detect foreground app changes in real time (user-granted in system settings) |

## Tech Stack

- **Frontend**: Flutter, Riverpod, Material 3, sqflite, SharedPreferences
- **Native Layer**: Kotlin, AccessibilityService, TYPE_APPLICATION_OVERLAY, SQLite
- **Security**: SHA-256 PIN hashing (crypto), 5-attempt lockout, PIN-gated settings
- **Communication**: MethodChannel (`com.example.app_lock/service`)

## Use Cases

- Two partners sharing one Android phone who want separate app privacy
- Parents locking specific apps on a child's device with a different PIN than the child's own profile
- Roommates or family members sharing a tablet with individual locked app lists
- Anyone who wants per-profile app locking without rooting their device
- Developers looking for a reference implementation of Flutter + Kotlin Accessibility Service integration with overlay windows

---

<h3 align="center">Star this repo if you find it useful, it helps others discover it and keeps development going!</h3>
