// Riverpod providers for profile state management
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_profile.dart';
import '../../../services/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((Ref ref) {
  return ProfileRepository();
});

final profileListProvider =
    AsyncNotifierProvider<ProfileListNotifier, List<UserProfile>>(
  ProfileListNotifier.new,
);

class ProfileListNotifier extends AsyncNotifier<List<UserProfile>> {
  @override
  Future<List<UserProfile>> build() async {
    final ProfileRepository repository =
        ref.watch(profileRepositoryProvider);
    return repository.getAllProfiles();
  }

  Future<int> addProfile({
    required String name,
    required String emoji,
    required String pin,
  }) async {
    final ProfileRepository repository =
        ref.read(profileRepositoryProvider);
    final UserProfile created =
        await repository.createProfile(name: name, emoji: emoji, pin: pin);
    if (!ref.mounted) return created.id!;
    final List<UserProfile> profiles = await repository.getAllProfiles();
    if (!ref.mounted) return created.id!;
    state = AsyncData(profiles);
    return created.id!;
  }

  Future<void> updateProfile({
    required int id,
    required String name,
    required String emoji,
  }) async {
    final ProfileRepository repository = ref.read(profileRepositoryProvider);
    try {
      await repository.updateProfile(id: id, name: name, emoji: emoji);
      if (!ref.mounted) return;
      final List<UserProfile> profiles = await repository.getAllProfiles();
      if (!ref.mounted) return;
      state = AsyncData(profiles);
    } catch (error, stackTrace) {
      debugPrint('Failed to update profile: $error');
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> changePin(int id, String newPin) async {
    final ProfileRepository repository = ref.read(profileRepositoryProvider);
    try {
      await repository.changePin(id, newPin);
    } catch (error) {
      debugPrint('Failed to change PIN: $error');
    }
  }

  Future<void> deleteProfile(int id) async {
    final ProfileRepository repository =
        ref.read(profileRepositoryProvider);
    try {
      await repository.deleteProfile(id);
      if (!ref.mounted) return;
      final List<UserProfile> profiles = await repository.getAllProfiles();
      if (!ref.mounted) return;
      state = AsyncData(profiles);
    } catch (error, stackTrace) {
      debugPrint('Failed to delete profile: $error');
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> saveLockedApps(int profileId, List<String> packages) async {
    final ProfileRepository repository = ref.read(profileRepositoryProvider);
    try {
      await repository.saveLockedApps(profileId, packages);
      if (!ref.mounted) return;
      ref.invalidate(lockedAppsCountProvider);
    } catch (error) {
      debugPrint('Failed to save locked apps: $error');
    }
  }

  Future<List<String>> getLockedApps(int profileId) async {
    final ProfileRepository repository = ref.read(profileRepositoryProvider);
    return repository.getLockedApps(profileId);
  }

  Future<void> resetAll() async {
    final ProfileRepository repository = ref.read(profileRepositoryProvider);
    try {
      await repository.resetAllProfiles();
      if (!ref.mounted) return;
      state = const AsyncData([]);
      ref.invalidate(lockedAppsCountProvider);
    } catch (error, stackTrace) {
      debugPrint('Failed to reset profiles: $error');
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> reload() async {
    ref.invalidateSelf();
  }
}

final lockedAppsCountProvider =
    FutureProvider<Map<int, int>>((Ref ref) async {
  final ProfileRepository repository = ref.watch(profileRepositoryProvider);
  return repository.getLockedAppsCountForAll();
});
