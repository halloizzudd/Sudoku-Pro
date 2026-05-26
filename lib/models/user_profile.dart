import 'dart:convert';

// UC-19/UC-20: identitas pemain yang ditampilkan di Profile & diedit di Edit
// Profile. Sumber akhir: backend (GET/PATCH /users/me). MVP dummy + persist
// lokal via SettingsService/LocalStorage.
class UserProfile {
  final String username;
  final String email;
  final String rankTitle; // contoh: "Grandmaster II"
  final bool isPro;
  final String? avatarPath; // path lokal/URL avatar; null = default icon

  const UserProfile({
    this.username = 'PlayerOne',
    this.email = 'player@sudokupro.app',
    this.rankTitle = 'Grandmaster II',
    this.isPro = true,
    this.avatarPath,
  });

  UserProfile copyWith({
    String? username,
    String? email,
    String? rankTitle,
    bool? isPro,
    String? avatarPath,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
      rankTitle: rankTitle ?? this.rankTitle,
      isPro: isPro ?? this.isPro,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toMap() => {
        'username': username,
        'email': email,
        'rankTitle': rankTitle,
        'isPro': isPro,
        'avatarPath': avatarPath,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        username: map['username'] ?? 'PlayerOne',
        email: map['email'] ?? 'player@sudokupro.app',
        rankTitle: map['rankTitle'] ?? 'Grandmaster II',
        isPro: map['isPro'] ?? false,
        avatarPath: map['avatarPath'],
      );

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
