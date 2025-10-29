class AppSettings {
  final String googleMapApi;
  final String appAndroidVersion;
  final String appIosVersion;
  final bool appAndroidForceUpdate;
  final bool appIosForceUpdate;
  final bool appMaintenanceMode;
  final String supportEmailId;
  final String contactEmailId;
  final String contactNumber;
  final String whatsappNumber;
  final String updateTitle;
  final String updateMessage;
  final String playStoreLink;
  final String appStoreLink;
  final String termsAndConditionUrl;
  final String privacyUrl;

  AppSettings({
    required this.googleMapApi,
    required this.appAndroidVersion,
    required this.appIosVersion,
    required this.appAndroidForceUpdate,
    required this.appIosForceUpdate,
    required this.appMaintenanceMode,
    required this.supportEmailId,
    required this.contactEmailId,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.updateTitle,
    required this.updateMessage,
    required this.playStoreLink,
    required this.appStoreLink,
    required this.termsAndConditionUrl,
    required this.privacyUrl,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      googleMapApi: json['googleMapApi'] ?? '',
      appAndroidVersion: json['appAndroidVersion'] ?? '',
      appIosVersion: json['appIosVersion'] ?? '',
      appAndroidForceUpdate: json['appAndroidForceUpdate'] ?? false,
      appIosForceUpdate: json['appIosForceUpdate'] ?? false,
      appMaintenanceMode: json['appMaintenanceMode'] ?? false,
      supportEmailId: json['supportEmailId'] ?? '',
      contactEmailId: json['contactEmailId'] ?? '',
      contactNumber: json['conatctNumber'] ?? '', // Note: API has typo
      whatsappNumber: json['whatsappNumber'] ?? '',
      updateTitle: json['updateTitle'] ?? '',
      updateMessage: json['updateMessage'] ?? '',
      playStoreLink: json['playStoreLink'] ?? '',
      appStoreLink: json['appStoreLink'] ?? '',
      termsAndConditionUrl: json['termsAndConditionUrl'] ?? '',
      privacyUrl: json['privacyUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'googleMapApi': googleMapApi,
      'appAndroidVersion': appAndroidVersion,
      'appIosVersion': appIosVersion,
      'appAndroidForceUpdate': appAndroidForceUpdate,
      'appIosForceUpdate': appIosForceUpdate,
      'appMaintenanceMode': appMaintenanceMode,
      'supportEmailId': supportEmailId,
      'contactEmailId': contactEmailId,
      'conatctNumber': contactNumber,
      'whatsappNumber': whatsappNumber,
      'updateTitle': updateTitle,
      'updateMessage': updateMessage,
      'playStoreLink': playStoreLink,
      'appStoreLink': appStoreLink,
      'termsAndConditionUrl': termsAndConditionUrl,
      'privacyUrl': privacyUrl,
    };
  }
}
