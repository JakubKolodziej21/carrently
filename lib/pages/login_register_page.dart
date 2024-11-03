import 'package:carrently/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> signInWithGoogle() async {
    try {
      User? user = await Auth().signInWithGoogle();
      if (user != null) {
        print('Zalogowano jako: ${user.displayName}');
        // Możesz tutaj przekierować użytkownika do innej strony lub zaktualizować interfejs
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

  Widget _title() {
    return Text(isLogin ? 'Logowanie' : 'Rejestracja');
  }

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

  Widget _googleSignInButton() {
    return ElevatedButton(
      onPressed: signInWithGoogle,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 243, 163, 33),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Zaloguj się przez Google'),
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
              _googleSignInButton(), // Dodany przycisk logowania przez Google
              const SizedBox(height: 10),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

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
