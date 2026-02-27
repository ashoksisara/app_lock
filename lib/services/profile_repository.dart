// Repository abstracting profile persistence — local-only for now, remote sync plugs in here later
import '../core/utils/pin_hasher.dart';
import '../models/user_profile.dart';
import 'database_service.dart';

class ProfileRepository {
  final DatabaseService _db;

  ProfileRepository({DatabaseService? db})
      : _db = db ?? DatabaseService.instance;

  Future<UserProfile> createProfile({
    required String name,
    required String emoji,
    required String pin,
  }) async {
    final DateTime now = DateTime.now();
    final UserProfile profile = UserProfile(
      name: name.trim(),
      emoji: emoji,
      hashedPin: PinHasher.hash(pin),
      createdAt: now,
      updatedAt: now,
    );

    final int id = await _db.insert(
      DatabaseService.tableProfiles,
      profile.toMap(),
    );

    return profile.copyWith(id: id);
  }

  Future<List<UserProfile>> getAllProfiles() async {
    final List<Map<String, dynamic>> maps =
        await _db.queryAll(DatabaseService.tableProfiles);
    return maps.map(UserProfile.fromMap).toList();
  }

  Future<UserProfile?> getProfileById(int id) async {
    final Map<String, dynamic>? map =
        await _db.queryById(DatabaseService.tableProfiles, id);
    return map != null ? UserProfile.fromMap(map) : null;
  }

  Future<void> deleteProfile(int id) async {
    await _db.delete(DatabaseService.tableProfiles, id);
  }

  Future<bool> verifyPin(int profileId, String pin) async {
    final UserProfile? profile = await getProfileById(profileId);
    if (profile == null) return false;
    return PinHasher.verify(pin, profile.hashedPin);
  }

  // TODO: Add remote sync methods here when online connectivity is implemented
  // Future<void> syncProfiles() async { ... }
  // Future<void> pushToRemote(UserProfile profile) async { ... }
}
