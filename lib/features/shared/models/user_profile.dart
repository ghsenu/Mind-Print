import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    required this.email,
    this.profilePhoto,
    this.language = 'en',
    this.yearOfStudy = '',
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.offlineSyncEnabled = true,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String displayName;
  final String email;
  final String? profilePhoto;
  final String language; // 'en' | 'si' | 'ta'
  final String yearOfStudy;
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final bool offlineSyncEnabled;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfile.initial(
    String userId,
    String email, {
    String displayName = '',
  }) {
    final now = DateTime.now();
    return UserProfile(
      userId: userId,
      displayName:
          displayName.isNotEmpty ? displayName : email.split('@').first,
      email: email,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserProfile(
      userId: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      profilePhoto: data['profilePhoto'] as String?,
      language: data['language'] as String? ?? 'en',
      yearOfStudy: data['yearOfStudy'] as String? ?? '',
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      offlineSyncEnabled: data['offlineSyncEnabled'] as bool? ?? true,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'displayName': displayName,
    'email': email,
    if (profilePhoto != null) 'profilePhoto': profilePhoto,
    'language': language,
    'yearOfStudy': yearOfStudy,
    'biometricEnabled': biometricEnabled,
    'notificationsEnabled': notificationsEnabled,
    'offlineSyncEnabled': offlineSyncEnabled,
    'onboardingCompleted': onboardingCompleted,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? profilePhoto,
    String? language,
    String? yearOfStudy,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    bool? offlineSyncEnabled,
    bool? onboardingCompleted,
    DateTime? updatedAt,
  }) => UserProfile(
    userId: userId,
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    profilePhoto: profilePhoto ?? this.profilePhoto,
    language: language ?? this.language,
    yearOfStudy: yearOfStudy ?? this.yearOfStudy,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    offlineSyncEnabled: offlineSyncEnabled ?? this.offlineSyncEnabled,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
