import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final auth = FirebaseAuth.instance;
  String email = '', password = '';
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Email"),
              onChanged: (value) => email = value,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
              onChanged: (value) => password = value,
            ),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value!;
                    });
                  },
                ),
                const Text("Remember Me"),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (email == '' || password == '') {
                    showToast("Enter your Credentials");
                  } else {
                    await auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (rememberMe) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);
                    }
                    if (context.mounted) {
                      showToast("Login Successful!");

                      if (email.toLowerCase() == "admin@gmail.com") {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isAdmin', true);
                        Navigator.pushReplacementNamed(context, "/admin");
                      } else {
                        email = email.split('@')[0];
                        DataSnapshot usernameRef = await FirebaseDatabase
                            .instance
                            .ref()
                            .child("users/$email/username")
                            .get();
                        String username = usernameRef.value.toString();

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString("username", username);
                        Navigator.pushReplacementNamed(context, "/home");
                      }
                    }
                  }
                } catch (e) {
                  showToast("Invalid Credentials, Try again");
                }
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (email == '') {
                    showToast("Enter your email to reset your password");
                  } else {
                    await auth.sendPasswordResetEmail(email: email);
                    if (context.mounted) {
                      showToast("Password reset email sent!");
                    }
                  }
                } catch (e) {
                  showToast(e.toString());
                }
              },
              child: const Text("Forgot Password?"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, "/signup"),
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }
}
