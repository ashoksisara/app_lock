# Multi-Profile App Locker

A Flutter + Kotlin Android app that lets two people share one device while keeping their apps private. Each person creates a profile with a separate PIN and locks whichever apps they want — when someone tries to open a locked app, they must enter the correct profile PIN to continue.

---

## Features

**Multi-Profile Support** — Two independent profiles, each with its own name, emoji avatar, and 4-digit PIN. Each profile locks a separate set of apps.

**Native Lock Overlay** — Kotlin-based `TYPE_APPLICATION_OVERLAY` window drawn on top of locked apps. Falls back to a dedicated `LockActivity` when needed. Both support dark/light mode and a profile picker.

**Onboarding Flow** — Three-page introduction followed by a step-by-step profile setup (choose avatar, set PIN, confirm PIN).

**App Selection** — Browse all installed apps organized by category (Social, Google, Entertainment, Other) with search and a live selection counter.

**PIN Security** — PINs are hashed with SHA-256 before storage. Wrong PIN attempts trigger shake animation and a 5-attempt lockout with 30-second cooldown.

**Settings** — Re-lock timing configuration, dark mode toggle, theme color selection, change PIN flow (requires current PIN verification), and a danger zone for full reset.

**Boot Persistence** — `BootReceiver` re-enables protection after device restarts.

**Biometric Auth (planned)** — `local_auth` dependency is included; biometric unlock is declared in settings but not yet wired.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI & App Logic | Flutter (Dart 3.11+) |
| State Management | Riverpod |
| Local Database | sqflite |
| Key-Value Storage | SharedPreferences |
| PIN Hashing | crypto (SHA-256) |
| Biometrics | local_auth |
| Installed Apps List | installed_apps |
| Background Service | Kotlin AccessibilityService |
| Lock Screen | Kotlin Overlay / LockActivity |
| Flutter ↔ Native | MethodChannel (`com.example.app_lock/service`) |

---

## Android Permissions

| Permission | Reason |
|---|---|
| `SYSTEM_ALERT_WINDOW` | Draw lock overlay on top of other apps |
| Accessibility Service | Detect foreground app changes (granted by user in system settings) |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.11 or higher
- Android SDK with minimum API level matching your `build.gradle`
- A physical Android device (accessibility services do not work reliably on emulators)

### Setup

```bash
git clone https://github.com/<your-username>/app_lock.git
cd app_lock
flutter pub get
flutter run
```

