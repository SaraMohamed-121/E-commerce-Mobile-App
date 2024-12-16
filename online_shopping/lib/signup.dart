import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => SignupState();
}

class SignupState extends State<Signup> {
  final auth = FirebaseAuth.instance;
  final db = FirebaseDatabase.instance.ref();
  final formKey = GlobalKey<FormState>();
  String username = '',
      email = '',
      password = '',
      confirmPassword = '',
      birthdate = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Username"),
                onChanged: (value) => username = value,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                  decoration: const InputDecoration(labelText: "Email"),
                  onChanged: (value) => email = value,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onChanged: (value) => password = value,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
                onChanged: (value) => confirmPassword = value,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Birthdate"),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      birthdate = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                readOnly: true,
                controller: TextEditingController(text: birthdate),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (username == '' ||
                      email == '' ||
                      password == '' ||
                      confirmPassword == '' ||
                      birthdate == '') {
                    showToast("Please fill all fields");
                  } else if (password != confirmPassword) {
                    showToast("Passwords don't match");
                  } else {
                    if (formKey.currentState!.validate()) {
                      try {
                        await auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        email = email.split('@')[0];
                        await db.child("users/$email").set({
                          "username": username,
                          "birthdate": birthdate,
                        });
                        if (context.mounted) {
                          showToast("Registration Successful!");
                          Navigator.pushNamed(context, "/login");
                        }
                      } catch (e) {
                        showToast(e.toString());
                      }
                    }
                  }
                },
                child: const Text("Register"),
              ),
              TextButton(
                onPressed: () => checkLoginStatus(context),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isAdmin = prefs.getBool('isAdmin') ?? false;

    if (isLoggedIn) {
      if (isAdmin) {
        Navigator.pushNamed(context, "/admin");
      } else {
        Navigator.pushNamed(context, "/home");
      }
    } else {
      Navigator.pushNamed(context, "/login");
    }
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
