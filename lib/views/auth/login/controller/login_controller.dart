import 'dart:io';

import 'package:doda_work/core/utils/app_storage.dart';
import 'package:doda_work/core/utils/basic_import.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/api/services/api.dart';
import '../../../../core/api/services/auths.dart';
import '../../../../core/utils/message_helper.dart';
import '../../../../routes/routes.dart';
import '../model/login_model.dart';

class LoginController extends GetxController {
  // user
  //dodauser45@yopmail.com
  //123654

  /// FORM
  final formKey = GlobalKey<FormState>();

  /// EMAIL
  final emailController = TextEditingController();
  final emailFocus = FocusNode();

  /// PASSWORD
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();
  final rememberMe = false.obs;

  /// LOADING
  final isLoading = false.obs;

  /// FIREBASE
  final firebaseUser = Rxn<fb.User>();
  fb.User? get user => firebaseUser.value;

  static final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  static fb.User? currentUser() => _auth.currentUser;

  @override
  void onInit() {
    // TODO: implement onInit

    if (kDebugMode) {
      emailController.text = "xyzt@yopmail.com";
      passwordController.text = "123456";
    }
    super.onInit();
  }

  // =======================================
  // 🔥 EMAIL + PASSWORD LOGIN
  // =======================================

  Future<dynamic> loginProcess() async {
    return await AuthService.loginService(
      isLoading: isLoading,
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  // =======================================
  // 🔥 GOOGLE SIGN IN
  // =======================================
  Future<fb.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();

      if (googleUser == null) {
        CustomSnackBar.error("Google sign-in was cancelled");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final fb.UserCredential userCredential = await _auth.signInWithCredential(
        fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );

      firebaseUser.value = userCredential.user;

      if (kDebugMode) {
        debugPrint("UID   : ${userCredential.user?.uid}");
        debugPrint("Email : ${userCredential.user?.email}");
        debugPrint("Name  : ${userCredential.user?.displayName}");
        debugPrint("Token : ${googleAuth.idToken?.substring(0, 30)}...");
      }

      await ApiRequest.post(
        fromJson: LoginModel.fromJson,
        endPoint: '/auth/google-login',
        isLoading: isLoading,
        // showSuccessSnackBar: true,
        body: {
          "provider": "google",
          "idToken": googleAuth.idToken,
          "role": AppStorage.role.toString(),
        },
        onSuccess: (result) {
          final role = result.data.user.authId.role.toUpperCase();
          final id = result.data.user.id;

          AppStorage.save(uId: id);
          AppStorage.save(token: result.data.accessToken, isLoggedIn: true);
          AppStorage.saveRole(role);
          AppStorage.isVendor = role == "PROVIDER";

          if (role == "PROVIDER" || role == "USER") {
            Get.offAllNamed(Routes.navigationScreen);
          } else {
            MessageHelper.showError("Please Select Your Role.\nThank you");
          }
        },
      );

      return userCredential.user;
    } on fb.FirebaseAuthException catch (e) {
      firebaseUser.value = null;
      CustomSnackBar.error(_firebaseError(e.code, e.message));
      return null;
    } on PlatformException catch (e) {
      await _auth.signOut();
      firebaseUser.value = null;
      final Map<String, String> errors = {
        'sign_in_failed': "Sign-in failed. Please check SHA-1 configuration",
        'network_error': "Network error. Check your internet connection",
      };
      CustomSnackBar.error(
        errors[e.code] ?? "Sign-in failed: ${e.message ?? 'Unknown error'}",
      );
      return null;
    } catch (e) {
      await _auth.signOut();
      firebaseUser.value = null;
      CustomSnackBar.error("An unexpected error occurred: ${e.toString()}");
      return null;
    }
  }

  // =======================================
  // 🔥 GOOGLE SIGN OUT
  // =======================================
  Future<void> signOutGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      firebaseUser.value = null;
    } catch (e) {
      CustomSnackBar.error("Unable to sign out");
    }
  }

  // =======================================
  // 🔥 APPLE SIGN IN (iOS / macOS Only)
  // =======================================
  Future<fb.UserCredential?> signInWithApple() async {
    try {
      if (kIsWeb || (!Platform.isIOS && !Platform.isMacOS)) {
        CustomSnackBar.error("Apple Sign-In is only available on iOS/macOS");
        return null;
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (appleCredential.identityToken == null) {
        CustomSnackBar.error("Failed to get Apple credentials");
        return null;
      }

      final fb.UserCredential userCredential = await _auth.signInWithCredential(
        fb.OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        ),
      );

      firebaseUser.value = userCredential.user;

      // প্রথমবার login এ name update
      if (userCredential.user?.displayName == null &&
          appleCredential.givenName != null) {
        final String displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
          await userCredential.user!.reload();
        }
      }

      if (kDebugMode) {
        debugPrint("UID   : ${userCredential.user?.uid}");
        debugPrint("Email : ${userCredential.user?.email}");
        debugPrint("Name  : ${userCredential.user?.displayName}");
        debugPrint(
          "Token : ${appleCredential.identityToken?.substring(0, 30)}...",
        );
      }

      await ApiRequest.post(
        fromJson: LoginModel.fromJson,
        endPoint: '/auth/apple',
        isLoading: isLoading,
        showSuccessSnackBar: true,
        body: {"identity_token": appleCredential.identityToken},
        onSuccess: (result) {
          final role = result.data.user.authId.role.toUpperCase();
          final id = result.data.user.id;

          debugPrint("User Role: $role");

          AppStorage.save(uId: id);
          debugPrint('-------------------------------');
          debugPrint('U ID = ${AppStorage.uId}');

          AppStorage.save(token: result.data.accessToken, isLoggedIn: true);

          AppStorage.saveRole(role);
          AppStorage.isVendor = role == "PROVIDER";

          // Navigate based on role
          if (role == "PROVIDER") {
            Get.offAllNamed(Routes.navigationScreen);
          } else if (role == "USER") {
            Get.offAllNamed(Routes.navigationScreen);
          } else {
            MessageHelper.showError("Please Select Your Role.\nThank you");
          }
        },
      );

      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      final Map<AuthorizationErrorCode, String> errors = {
        AuthorizationErrorCode.canceled: "Apple Sign-In was cancelled",
        AuthorizationErrorCode.failed: "Apple Sign-In failed",
        AuthorizationErrorCode.invalidResponse: "Invalid response from Apple",
        AuthorizationErrorCode.notHandled: "Apple Sign-In not handled",
        AuthorizationErrorCode.unknown: "Unknown error occurred",
      };
      CustomSnackBar.error(
        errors[e.code] ?? "Apple Sign-In error: ${e.message}",
      );
      return null;
    } on fb.FirebaseAuthException catch (e) {
      firebaseUser.value = null;
      CustomSnackBar.error(_firebaseError(e.code, e.message));
      return null;
    } catch (e) {
      CustomSnackBar.error("An unexpected error occurred: ${e.toString()}");
      return null;
    }
  }

  // =======================================
  // 🔥 APPLE SIGN OUT
  // =======================================
  Future<void> signOutApple() async {
    try {
      await _auth.signOut();
      firebaseUser.value = null;
    } catch (e) {
      CustomSnackBar.error("Unable to sign out");
    }
  }

  // =======================================
  // 🔥 FIREBASE ERROR HELPER
  // =======================================
  String _firebaseError(String code, String? message) {
    const Map<String, String> errors = {
      'account-exists-with-different-credential':
          "An account already exists with a different sign-in method",
      'invalid-credential': "Invalid credentials. Please try again",
      'operation-not-allowed': "This sign-in method is not enabled",
      'user-disabled': "This user account has been disabled",
      'user-not-found': "No user found with this account",
    };
    return errors[code] ?? "Authentication failed: $message";
  }
}
