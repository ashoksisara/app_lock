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

  Future<void> addProfile({
    required String name,
    required String emoji,
    required String pin,
  }) async {
    final ProfileRepository repository =
        ref.read(profileRepositoryProvider);
    try {
      await repository.createProfile(name: name, emoji: emoji, pin: pin);
      if (!ref.mounted) return;
      final List<UserProfile> profiles = await repository.getAllProfiles();
      if (!ref.mounted) return;
      state = AsyncData(profiles);
    } catch (error, stackTrace) {
      debugPrint('Failed to add profile: $error');
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
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

  Future<void> reload() async {
    ref.invalidateSelf();
  }
}
