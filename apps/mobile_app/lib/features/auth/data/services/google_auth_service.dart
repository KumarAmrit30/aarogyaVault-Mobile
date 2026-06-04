import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/core/errors/app_exception.dart';
import 'package:mobile_app/features/auth/domain/services/auth_service.dart';

class GoogleAuthService implements AuthService {
  GoogleAuthService(
    this._firebaseAuth, {
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize(
        serverClientId: AppConstants.googleWebClientId,
      );
      _initialized = true;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthException('Missing Google ID token.');
      }
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('Sign in canceled.');
      }
      throw AuthException(
        e.description ?? 'Google sign in failed.',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Firebase authentication failed.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign out failed.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
