import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/user_profile_service.dart';



class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
    // Explicitly using the Web Client ID for server exchange
    serverClientId: '56676639963-5ash2r7bopr3hca7hren22ig8d6qr5gj.apps.googleusercontent.com',
  );
  final UserProfileService _userProfileService = UserProfileService();
  
  AuthService() {
    print('🔧 [AuthService] Initialized');
    print('🔧 [AuthService] Firebase Auth instance: ${firebaseAuth.app.name}');
    print('🔧 [AuthService] Current user: ${firebaseAuth.currentUser?.email ?? "None"}');
  }
  
  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,

  }) async{
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async{
    return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async{
    await firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async{
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteAccount() async{
    await firebaseAuth.currentUser?.delete();
  }
  


  Future<void> updatePassword({required String password}) async{
    await firebaseAuth.currentUser?.updatePassword(password);
  }

  Future<void> sendEmailVerification() async{
    await firebaseAuth.currentUser?.sendEmailVerification();
  }

  Future<UserCredential?> signInWithGoogle({bool forceAccountSelection = true}) async {
    try {
      print('🔵 [Google Sign-In] Starting sign-in process...');
      print('🔵 [Google Sign-In] Force account selection: $forceAccountSelection');
      
      if (forceAccountSelection) {
        // Ensure previous Google session is cleared so the account picker shows
        print('🔵 [Google Sign-In] Clearing previous session...');
        try {
          await googleSignIn.disconnect();
          print('✅ [Google Sign-In] Disconnected successfully');
        } catch (e) {
          print('⚠️ [Google Sign-In] Disconnect failed (this is normal): $e');
        }
        
        try {
          await googleSignIn.signOut();
          print('✅ [Google Sign-In] Signed out successfully');
        } catch (e) {
          print('⚠️ [Google Sign-In] Sign out failed: $e');
        }
      }
      
      // Trigger the authentication flow
      print('🔵 [Google Sign-In] Triggering authentication flow...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        print('⚠️ [Google Sign-In] User cancelled the sign-in');
        return null;
      }
      
      print('✅ [Google Sign-In] User selected: ${googleUser.email}');
      print('🔵 [Google Sign-In] User ID: ${googleUser.id}');
      print('🔵 [Google Sign-In] Display Name: ${googleUser.displayName}');

      // Obtain the auth details from the request
      print('🔵 [Google Sign-In] Obtaining authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('✅ [Google Sign-In] Authentication details obtained');
      print('🔵 [Google Sign-In] Access Token present: ${googleAuth.accessToken != null}');
      print('🔵 [Google Sign-In] ID Token present: ${googleAuth.idToken != null}');
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ [Google Sign-In] ERROR: Missing tokens!');
        print('   Access Token: ${googleAuth.accessToken}');
        print('   ID Token: ${googleAuth.idToken}');
        throw Exception('Failed to obtain authentication tokens from Google');
      }

      // Create a new credential
      print('🔵 [Google Sign-In] Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('✅ [Google Sign-In] Firebase credential created');

      // Sign in to Firebase with the Google credential
      print('🔵 [Google Sign-In] Signing in to Firebase...');
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      
      print('✅ [Google Sign-In] Successfully signed in to Firebase!');
      print('🔵 [Google Sign-In] Firebase User ID: ${userCredential.user?.uid}');
      print('🔵 [Google Sign-In] Firebase User Email: ${userCredential.user?.email}');
      
      // Store user profile information in local storage
      if (userCredential.user != null) {
        print('🔵 [Google Sign-In] Storing user profile...');
        await _userProfileService.storeProfileFromFirebaseUser(userCredential.user!);
        print('✅ [Google Sign-In] User profile stored');
      }
      
      print('🎉 [Google Sign-In] Sign-in process completed successfully!');
      return userCredential;
    } catch (e, stackTrace) {
      print('❌ [Google Sign-In] ERROR occurred during sign-in:');
      print('   Error type: ${e.runtimeType}');
      print('   Error message: $e');
      print('   Stack trace:');
      print(stackTrace.toString().split('\n').take(10).join('\n'));
      
      // Additional error details for PlatformException
      if (e is Exception) {
        print('   Exception details: ${e.toString()}');
      }
      
      rethrow;
    }
  }

  Future<void> signOutGoogle() async {
    try {
      // Disconnect ensures the next sign-in prompts for account selection
      try {
        await googleSignIn.disconnect();
      } catch (_) {}
      await googleSignIn.signOut();
    } finally {
      // Clear stored profile data
      await _userProfileService.clearStoredProfile();
      await firebaseAuth.signOut();
    }
  }
}