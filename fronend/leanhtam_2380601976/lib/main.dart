import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth_screen.dart'; // <--- Đổi sang import auth_screen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đề Kiểm Tra LTDD',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthScreen(), // <--- Gọi AuthScreen làm màn hình chính
    );
  }
}