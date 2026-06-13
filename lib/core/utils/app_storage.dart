import 'package:get_storage/get_storage.dart';

import 'app_storage_model.dart';

class AppStorage {
  static final GetStorage _storage = GetStorage();

  // ========================= KEYS =========================
  static const String _tokenKey = 'token';
  static const String _uIdKey = 'uId';
  static const String _isUserKey = 'isUsers';
  static const String _temporaryTokenKey = 'temporaryToken';
  static const String _mobileCodeKey = 'mobileCode';
  static const String _onboardSaveKey = 'onboardSave';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _isEmailVerifiedKey = 'isEmailVerified';
  static const String _isKycVerifiedKey = 'isKycVerified';
  static const String _isSmsVerifiedKey = 'isSmsVerified';
  static const String _kycStatusKey = 'isKycStatus';
  static const String _isVendorKey = 'isVendor';
  static const String _profileKey = 'profile';
  static const String _roleKey = 'role';

  static const String _rememberMeKey = 'rememberMe';
  static const String _savedEmailKey = 'savedEmail';
  static const String _savedPasswordKey = 'savedPassword';

  static const String _savedNameKey = 'savedName';

  // ========================= REMEMBER ME =========================
  static bool get rememberMe => _storage.read(_rememberMeKey) ?? false;
  static set rememberMe(bool value) => _storage.write(_rememberMeKey, value);

  static String get savedEmail => _storage.read(_savedEmailKey) ?? '';
  static set savedEmail(String value) => _storage.write(_savedEmailKey, value);

  // name company name
  static String get savedName => _storage.read(_savedNameKey) ?? '';
  static set savedName(String value) => _storage.write(_savedNameKey, value);

  static String get savedPassword => _storage.read(_savedPasswordKey) ?? '';
  static set savedPassword(String value) =>
      _storage.write(_savedPasswordKey, value);

  // ========================= SAVE DATA =========================
  static Future<void> save({
    String? token,
    String? uId,
    String? isUsers,
    String? temporaryToken,
    String? mobileCode,
    bool? onboardSave,
    bool? isLoggedIn,
    bool? isEmailVerified,
    bool? isKycVerified,
    bool? isSmsVerified,
    bool? isKycStatus,
    bool? isVendor,
    String? role,
  }) async {
    if (token != null) {
      await _storage.write(_tokenKey, token.replaceAll('"', '').trim());
    }
    if (temporaryToken != null) {
      await _storage.write(_temporaryTokenKey, temporaryToken);
    }
    if (uId != null) await _storage.write(_uIdKey, uId);
    if (isUsers != null) await _storage.write(_isUserKey, isUsers);
    if (mobileCode != null) await _storage.write(_mobileCodeKey, mobileCode);
    if (onboardSave != null) await _storage.write(_onboardSaveKey, onboardSave);
    if (isLoggedIn != null) await _storage.write(_isLoggedInKey, isLoggedIn);
    if (isEmailVerified != null) {
      await _storage.write(_isEmailVerifiedKey, isEmailVerified);
    }
    if (isKycVerified != null) {
      await _storage.write(_isKycVerifiedKey, isKycVerified);
    }
    if (isSmsVerified != null) {
      await _storage.write(_isSmsVerifiedKey, isSmsVerified);
    }
    if (isKycStatus != null) await _storage.write(_kycStatusKey, isKycStatus);
    if (isVendor != null) isVendor = isVendor; // use setter
    if (role != null) await saveRole(role);
  }

  static Future<void> saveProfile(Map<String, dynamic> profileJson) async {
    await _storage.write(_profileKey, profileJson);
  }

  // ========================= GETTERS =========================
  static String get token => (_storage.read(_tokenKey) ?? '').trim();

  static String get temporaryToken => _storage.read(_temporaryTokenKey) ?? '';

  static String get uId => _storage.read(_uIdKey) ?? '';

  static String get users => _storage.read(_isUserKey) ?? '';

  static String get mobileCode => _storage.read(_mobileCodeKey) ?? '';

  static bool get isLoggedIn => _storage.read(_isLoggedInKey) ?? false;

  static bool get onboardSave => _storage.read(_onboardSaveKey) ?? false;

  static bool get isEmailVerified =>
      _storage.read(_isEmailVerifiedKey) ?? false;

  static bool get isKycVerified => _storage.read(_isKycVerifiedKey) ?? false;

  static bool get isSmsVerified => _storage.read(_isSmsVerifiedKey) ?? false;

  static bool get isKycStatus => _storage.read(_kycStatusKey) ?? false;

  static bool get isVendor => _storage.read(_isVendorKey) ?? false;

  static Map<String, dynamic>? get profile => _storage.read(_profileKey);

  // ✅ New getter for logged-in user ID
  static String get userId {
    final profileData = _storage.read(_profileKey);
    if (profileData != null && profileData['id'] != null) {
      return profileData['id'].toString();
    }
    return '';
  }

  // ========================= ROLE MANAGEMENT =========================
  static Future<void> saveRole(String role) async {
    await _storage.write(_roleKey, role.toUpperCase().trim());
    _storage.write(_isVendorKey, role.toUpperCase() == "PROVIDER");
  }

  static String get role => (_storage.read(_roleKey) ?? "USER").toUpperCase();

  static bool get isUser => role == "USER";

  static bool get isProvider => role == "PROVIDER";

  // ========================= SETTERS =========================
  static set isVendor(bool value) {
    _storage.write(_isVendorKey, value);
    saveRole(value ? "PROVIDER" : "USER");
  }

  // ========================= HELPER METHODS =========================
  static AppStorageModel get common {
    return AppStorageModel(
      uId: uId,
      token,
      onboardSave,
      isLoggedIn,
      isEmailVerified,
      isKycVerified,
      isSmsVerified,
      isKycStatus ? 1 : 0,
      temporaryToken: temporaryToken,
      mobileCode: mobileCode,
      isUsers: users,
    );
  }

  static bool get seenOnboarding => _storage.read(_onboardSaveKey) ?? false;

  static set seenOnboarding(bool value) =>
      _storage.write(_onboardSaveKey, value);

  // ========================= CLEAR DATA =========================
  static Future<void> clear() async => await _storage.erase();
}
