import 'package:carrently/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// LoginPage widget allows users to sign in, register, and reset their password.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  /// Signs in the user with email and password using Firebase authentication.
  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = getFirebaseErrorMessage(e.code);
      });
      _showErrorDialog();
    }
  }

  /// Registers a new user with email and password using Firebase authentication.
  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = getFirebaseErrorMessage(e.code);
      });
      _showErrorDialog();
    }
  }

  /// Sends a password reset email to the user if they have forgotten their password.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessageDialog('Wysłano e-mail z resetowaniem hasła.');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = getFirebaseErrorMessage(e.code);
      });
      _showErrorDialog();
    }
  }

  /// Signs in the user with Google account using Firebase authentication.
  Future<void> signInWithGoogle() async {
    try {
      User? user = await Auth().signInWithGoogle();
      if (user != null) {
        print('Zalogowano jako: ${user.displayName}');
        // Optional: redirect the user to another screen or update the UI
      } else {
        setState(() {
          errorMessage = 'Logowanie nie powiodło się';
        });
        _showErrorDialog();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = getFirebaseErrorMessage(e.code);
      });
      _showErrorDialog();
    }
  }

  /// Displays an error dialog with the current error message.
  void _showErrorDialog() {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coś poszło nie tak'),
          content: Text(errorMessage!),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  errorMessage = '';
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Displays an informational dialog with a custom message.
  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informacja'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Widget that displays either "Logowanie" or "Rejestracja" based on the mode.
  Widget _title() {
    return Text(
      isLogin ? 'Logowanie' : 'Rejestracja',
      style: const TextStyle(color: Colors.blueAccent),
    );
  }

  /// Entry field widget for entering email or password.
  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Entry field widget for entering password with obscured text.
  Widget _entryPasswordField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: title,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Submit button widget that either logs in or registers the user based on the mode.
  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 243, 163, 33),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(isLogin ? 'Zaloguj się' : 'Utwórz konto'),
    );
  }

  /// Button to toggle between login and registration modes.
  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: Text(isLogin ? 'Zarejestruj się' : 'Mam już konto'),
    );
  }

  /// Button to reset the user's password.
  Widget _resetPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          if (_controllerEmail.text.isEmpty) {
            setState(() {
              errorMessage = 'Wprowadź adres e-mail, aby zresetować hasło.';
            });
            _showErrorDialog();
          } else {
            sendPasswordResetEmail(_controllerEmail.text);
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 243, 156, 33),
        ),
        child: const Text(
          'Zapomniałeś hasła?',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  /// Google sign-in button with a custom image.
  Widget _googleSignInButton() {
    return GestureDetector(
      onTap: signInWithGoogle,
      child: Image.asset('assets/images/google_login_button.png'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 110, 179, 236), Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo_white.png',
                height: 300,
              ),
              const SizedBox(height: 20),
              _entryField('E-mail', _controllerEmail),
              const SizedBox(height: 10),
              _entryPasswordField('Hasło', _controllerPassword),
              const SizedBox(height: 8),
              _resetPasswordButton(),
              const SizedBox(height: 20),
              _submitButton(),
              const SizedBox(height: 10),
              _googleSignInButton(),
              const SizedBox(height: 10),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Maps Firebase error codes to user-friendly messages in Polish.
  String getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Nie znaleziono użytkownika dla podanego adresu e-mail';
      case 'wrong-password':
        return 'Nieprawidłowe hasło';
      case 'email-already-in-use':
        return 'Adres e-mail jest już używany';
      case 'invalid-email':
        return 'Nieprawidłowy format adresu e-mail';
      case 'operation-not-allowed':
        return 'Ta operacja nie jest dozwolona';
      case 'weak-password':
        return 'Hasło jest zbyt słabe';
      default:
        return 'Wystąpił nieznany błąd. Spróbuj ponownie później.';
    }
  }
}
