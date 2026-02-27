// Data model for a profile — holds name, avatar emoji, hashed PIN, and timestamps
class UserProfile {
  final int? id;
  final String name;
  final String emoji;
  final String hashedPin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    this.id,
    required this.name,
    required this.emoji,
    required this.hashedPin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      hashedPin: map['hashed_pin'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'emoji': emoji,
      'hashed_pin': hashedPin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? emoji,
    String? hashedPin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      hashedPin: hashedPin ?? this.hashedPin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
