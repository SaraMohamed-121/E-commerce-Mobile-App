import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login.dart';
import 'signup.dart';
import 'admin.dart';
import 'report.dart';
import 'chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/home': (context) => const Home(),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/admin': (context) => const Admin(),
        '/report': (context) => const Report(),
        '/chart': (context) => const Chart(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Shopping')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                checkLoginStatus(context);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/signup");
              },
              child: const Text('Signup'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    bool isAdmin = prefs.getBool('isAdmin') ?? false;

    if (isLoggedIn) {
      if (isAdmin) {
        Navigator.pushReplacementNamed(context, "/admin");
      } else {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }
}
