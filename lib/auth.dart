import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service to handle user sign-in, sign-up, and Google sign-in.
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Gets the current authenticated user.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Streams authentication state changes, returning `User` if signed in, `null` if signed out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs in a user with email and password.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registers a new user with email and password.
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the current user from Firebase authentication and Google Sign-In.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut(); // Logs out from Google SignIn
  }

  /// Signs in a user with Google account and returns the `User` object if successful.
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User canceled the sign-in

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  }
}

/// Gets the current user ID if the user is signed in.
String? getUserId() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}
