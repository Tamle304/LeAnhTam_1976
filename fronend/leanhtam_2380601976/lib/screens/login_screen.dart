import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_screen.dart';
import 'employee_screen.dart';
import 'student_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _routeByRole(String token, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cleanUser = username.trim().toLowerCase();
    String storedRole = prefs.getString('user_role_$cleanUser') ?? prefs.getString('user_role_$username') ?? '';

    if (cleanUser == 'le7292936@gmail.com' || cleanUser.contains('giang') || cleanUser.contains('teacher') || cleanUser.contains('gv') || cleanUser.contains('thay') || cleanUser.contains('employee') || cleanUser.contains('nhanvien')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
      return;
    }

    String lowerStored = storedRole.toLowerCase();

    if (cleanUser.contains('admin') || lowerStored.contains('admin')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
      return;
    }
    if (lowerStored.contains('giang') || lowerStored.contains('teacher') || lowerStored.contains('gv') || lowerStored.contains('thay') || lowerStored.contains('employee') || lowerStored.contains('nhanvien')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
      return;
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String tokenRole = (decodedToken['role'] ??
          decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
          'Student').toString().toLowerCase();

      if (tokenRole.contains('admin')) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
        return;
      }
      if (tokenRole.contains('teacher') || tokenRole.contains('giang') || tokenRole.contains('gv') || tokenRole.contains('employee') || tokenRole.contains('nhanvien')) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
        return;
      }
    } catch (_) {}

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StudentScreen()));
  }

  void _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin tài khoản!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);
    String username = _usernameController.text.trim();
    var result = await _apiService.login(username, _passwordController.text);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['status'] == true) {
      _routeByRole(result['token'], username);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Đăng nhập thất bại'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleRadiusIcon(), // Icon trang trí
                    const SizedBox(height: 16),
                    const Text(
                      'HỆ THỐNG ĐIỂM DANH',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    const Text(
                      'Đăng nhập để tiếp tục',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Tên đăng nhập',
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4A90E2)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4A90E2)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CircleRadiusIcon extends StatelessWidget {
  const CircleRadiusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.fingerprint, size: 50, color: Color(0xFF4A90E2)),
    );
  }
}