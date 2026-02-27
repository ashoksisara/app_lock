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

  Future<void> saveLockedApps(int profileId, List<String> packageNames) async {
    await _db.deleteWhere(
      DatabaseService.tableLockedApps,
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    for (final String pkg in packageNames) {
      await _db.insert(DatabaseService.tableLockedApps, {
        'profile_id': profileId,
        'package_name': pkg,
      });
    }
  }

  Future<List<String>> getLockedApps(int profileId) async {
    final List<Map<String, dynamic>> rows = await _db.queryWhere(
      DatabaseService.tableLockedApps,
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    return rows.map((Map<String, dynamic> r) => r['package_name'] as String).toList();
  }

  Future<int> getLockedAppsCount(int profileId) async {
    final int? count = await _db.count(
      DatabaseService.tableLockedApps,
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    return count ?? 0;
  }

  Future<Map<int, int>> getLockedAppsCountForAll() async {
    final List<Map<String, dynamic>> rows = await _db.queryWhere(
      DatabaseService.tableLockedApps,
      where: '1 = 1',
      whereArgs: [],
    );
    final Map<int, int> counts = {};
    for (final Map<String, dynamic> row in rows) {
      final int pid = row['profile_id'] as int;
      counts[pid] = (counts[pid] ?? 0) + 1;
    }
    return counts;
  }
}
