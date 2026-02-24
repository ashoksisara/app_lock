// Centralized string constants for labels, messages, and UI text
class AppStrings {
  AppStrings._();

  static const String appName = 'AppLocker';
  static const String appSubtitle = 'Multi Profile';
  static const String addProfile = 'Add Profile';
  static const String protectionActive = 'Protection Active';
  static const String protectionOff = 'Protection Off';
  static const String appsLocked = 'apps locked';
  static const String settingsTooltip = 'Settings';

  // Settings Screen
  static const String settings = 'Settings';
  static const String sectionProfiles = 'Profiles';
  static const String sectionSecurity = 'Security';
  static const String sectionProtection = 'Protection';
  static const String sectionAppearance = 'Appearance';
  static const String sectionAbout = 'About';
  static const String sectionDangerZone = 'Danger Zone';
  static const String manageProfiles = 'Manage Profiles';
  static const String switchProfile = 'Switch Active Profile';
  static const String changePIN = 'Change PIN';
  static const String useBiometrics = 'Use Biometrics';
  static const String intruderDetection = 'Intruder Detection';
  static const String intruderDetectionSub = 'Photo on wrong PIN attempts';
  static const String relockTiming = 'Re-lock Timing';
  static const String lockOnScreenOff = 'Lock on Screen Off';
  static const String backgroundService = 'Background Service';
  static const String darkMode = 'Dark Mode';
  static const String appLanguage = 'App Language';
  static const String appVersion = 'App Version';
  static const String privacyPolicy = 'Privacy Policy';
  static const String rateApp = 'Rate the App';
  static const String resetAllProfiles = 'Reset All Profiles';
  static const String resetAllProfilesSub = 'Permanently delete all profiles and locked apps';
  static const String uninstallProtection = 'Uninstall Protection';
  static const String uninstallProtectionSub = 'Allow app to be uninstalled';

  // Profile Setup Screen
  static const String newProfile = 'New Profile';
  static const String editProfile = 'Edit Profile';
  static const String stepOf = 'Step';
  static const String tapToChangeAvatar = 'Tap to change avatar';
  static const String profileName = 'Profile Name';
  static const String profileNameHint = 'e.g. John, Sarah, Profile 1';
  static const String setYourPIN = 'Set your PIN';
  static const String setYourPINSub = 'Choose a 4-digit PIN for this profile';
  static const String confirmYourPIN = 'Confirm your PIN';
  static const String confirmYourPINSub = 'Enter your PIN again to confirm';
  static const String saveProfile = 'Save Profile';
  static const String next = 'Next';

  // App Selection Screen
  static const String selectApps = 'Select Apps';
  static const String searchApps = 'Search apps...';
  static const String done = 'Done';
  static const String clearAll = 'Clear All';
  static const String appsSelected = 'apps selected';
  static const String saveAndContinue = 'Save & Continue';
  static const String categorySocial = 'Social';
  static const String categoryGoogle = 'Google';
  static const String categoryEntertainment = 'Entertainment';
  static const String categoryOther = 'Other';

  // Lock Screen
  static const String enterPINToUnlock = 'Enter PIN to unlock';
  static const String incorrectPIN = 'Incorrect PIN.';
  static const String attemptsRemaining = 'attempts remaining';
  static const String goBack = 'Go back';
  static const String profileAppLabel = "'s app";

  // Onboarding Screen
  static const String skip = 'Skip';
  static const String getStarted = 'Get Started';
  static const String onboardingTitle1 = 'One Device, Multiple Privacy';
  static const String onboardingTitle2 = 'Create Your Profile';
  static const String onboardingTitle3 = 'You\'re Always Protected';
  static const String onboardingDesc1 =
      'Lock any app under your own profile. Each person gets '
      'their own PIN and their own locked apps.';
  static const String onboardingDesc2 =
      'Set up a profile with your name, avatar and a secret '
      'PIN that only you know.';
  static const String onboardingDesc3 =
      'The moment someone opens your locked app, they\'ll need '
      'your PIN. Simple, private and secure.';
}
