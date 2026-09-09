/// MODEL
/// The signed-in user's profile + preferences, shown on the
/// Settings/Profile screen and used to greet them on the Home screen.
class UserProfileModel {
  String fullName;
  String email;
  String farmName;
  String planType; // 'FREE' | 'PRO'
  String language;
  bool notificationsEnabled;
  String? photoPath;

  UserProfileModel({
    this.fullName = '',
    this.email = '',
    this.farmName = '',
    this.planType = 'FREE',
    this.language = 'English',
    this.notificationsEnabled = true,
    this.photoPath,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
        fullName: (json['full_name'] ?? json['fullName'] ?? '') as String? ?? '',
        email: (json['email'] ?? '') as String? ?? '',
        farmName: (json['farm_name'] ?? json['farmName'] ?? '') as String? ?? '',
        planType: (json['plan_type'] ?? json['planType'] ?? 'FREE') as String? ?? 'FREE',
        language: (json['language'] ?? 'English') as String? ?? 'English',
        notificationsEnabled: (json['notifications_enabled'] ?? json['notificationsEnabled'] ?? true) as bool? ?? true,
        photoPath: (json['photo_path'] ?? json['photoPath']) as String?,
      );
}
