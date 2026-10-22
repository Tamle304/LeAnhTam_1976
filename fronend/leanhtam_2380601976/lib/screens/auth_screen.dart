import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/biometric_helper.dart';
import 'admin_screen.dart';
import 'employee_screen.dart';
import 'student_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Trạng thái tab: 0 = Đăng nhập, 1 = Đăng ký Email
  int _authMode = 0;
  // Trạng thái phương thức: 0 = Mật khẩu, 1 = Mã OTP
  int _loginMethod = 0;
  // Vai trò khi đăng ký
  String _registerRole = 'GiangVien';

  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final ApiService _apiService = ApiService();

  // Hàm chuyển hướng dựa theo Vai trò (Role)
  Future<void> _routeByRole(String token, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cleanUser = username.trim().toLowerCase();
    String storedRole = prefs.getString('user_role_$cleanUser') ?? prefs.getString('user_role_$username') ?? '';

    // Ép cứng tài khoản cụ thể này hoặc các tài khoản giảng viên sang EmployeeScreen
    if (cleanUser == 'le7292936@gmail.com' || cleanUser.contains('giang') || cleanUser.contains('teacher') || cleanUser.contains('gv') || cleanUser.contains('thay') || cleanUser.contains('employee') || cleanUser.contains('nhanvien')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
      return;
    }

    String lowerStored = storedRole.toLowerCase();

    // 1. Ưu tiên kiểm tra role đã lưu cục bộ hoặc từ khóa username
    if (cleanUser.contains('admin') || lowerStored.contains('admin')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
      return;
    }
    if (lowerStored.contains('giang') || lowerStored.contains('teacher') || lowerStored.contains('gv') || lowerStored.contains('thay') || lowerStored.contains('employee') || lowerStored.contains('nhanvien')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
      return;
    }

    // 2. Kiểm tra token từ server
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

    // 3. Mặc định Sinh viên
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const StudentScreen()));
  }

  // Hiển thị Popup nhập mã kích hoạt sau khi đăng ký thành công
  void _showVerifyDialog(String username) {
    final TextEditingController verifyCodeController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Kích hoạt tài khoản'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nhập mã kích hoạt đã được gửi tới email: $username'),
            const SizedBox(height: 15),
            TextField(
              controller: verifyCodeController,
              decoration: const InputDecoration(
                labelText: 'Mã xác nhận (Code)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              String code = verifyCodeController.text.trim();
              if (code.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);
              var res = await _apiService.registerVerify(username, code);
              setState(() => _isLoading = false);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res['message'] ?? 'Xác thực hoàn tất'),
                  backgroundColor: res['status'] == true || res['success'] == true ? Colors.green : Colors.redAccent,
                ),
              );

              if (res['status'] == true || res['success'] == true) {
                setState(() => _authMode = 0); // Chuyển về tab đăng nhập
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  // Hàm xử lý Gửi mã OTP
  Future<void> _handleSendOtp() async {
    String username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập Tên đăng nhập / Email trước!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang gửi mã OTP...'), duration: Duration(seconds: 1)),
    );

    var res = await _apiService.sendOtp(username);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? 'Đã gửi yêu cầu OTP'),
        backgroundColor: res['status'] == true || res['success'] == true ? Colors.green : Colors.redAccent,
      ),
    );
  }

  // Hàm xử lý Đăng nhập bằng Vân tay / Sinh trắc học
  Future<void> _handleBiometricLogin() async {
    bool authenticated = await BiometricHelper.authenticate();
    if (authenticated) {
      setState(() => _isLoading = true);
      String username = _usernameController.text.trim().isNotEmpty
          ? _usernameController.text.trim()
          : 'leanhtam_1976';
      var res = await _apiService.login(username, 'biometric');
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác thực vân tay thành công! Đang đăng nhập...'),
          backgroundColor: Colors.green,
        ),
      );
      _routeByRole(res['token'], username);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảm biến Vân tay không phản hồi hoặc đã bị hủy.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Hàm xử lý Đăng nhập, Xác thực OTP & Đăng ký
  Future<void> _handleSubmit() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String otp = _otpController.text.trim();

    // Validate dữ liệu đầu vào cơ bản
    if (username.isEmpty || (_authMode == 0 && _loginMethod == 0 && password.isEmpty) || (_authMode == 0 && _loginMethod == 1 && otp.isEmpty) || (_authMode == 1 && password.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_authMode == 1) {
        // --- XỬ LÝ ĐĂNG KÝ TÀI KHOẢN ---
        var result = await _apiService.register(username, password, role: _registerRole);
        setState(() => _isLoading = false);

        if (!mounted) return;

        if (result['status'] == true || result['success'] == true || result['statusCode'] == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Hãy nhập mã kích hoạt.'),
              backgroundColor: Colors.green,
            ),
          );
          // Hiển thị bảng nhập mã xác nhận đăng ký
          _showVerifyDialog(username);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Đăng ký thất bại!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // --- XỬ LÝ ĐĂNG NHẬP ---
        Map<String, dynamic> result;
        if (_loginMethod == 0) {
          // Đăng nhập bằng Mật khẩu
          result = await _apiService.login(username, password);
        } else {
          // Đăng nhập bằng mã OTP
          result = await _apiService.loginVerify(username, otp);
        }

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (result['status'] == true || result['token'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _routeByRole(result['token'], username);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Đăng nhập thất bại!'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kết nối Server: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B1B3A), Color(0xFF2C3E50), Color(0xFF4A90E2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'HỆ THỐNG ĐIỂM DANH & QUẢN LÝ LỚP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lê Anh Tâm - 1976 - Nhóm 01',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 30),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tab Đăng nhập / Đăng ký Email
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _authMode = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _authMode == 0 ? const Color(0xFF4A90E2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _authMode == 0 ? Colors.white : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _authMode = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _authMode == 1 ? const Color(0xFF4A90E2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Đăng ký Email',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _authMode == 1 ? Colors.white : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tùy chọn Mật khẩu / OTP ở tab Đăng nhập
                      if (_authMode == 0) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => _loginMethod = 0),
                                icon: const Icon(Icons.lock_outline, size: 18),
                                label: const Text('Bằng Mật khẩu'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _loginMethod == 0 ? const Color(0xFF4A90E2) : Colors.grey,
                                  side: BorderSide(color: _loginMethod == 0 ? const Color(0xFF4A90E2) : Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => _loginMethod = 1),
                                icon: const Icon(Icons.mark_email_read_outlined, size: 18),
                                label: const Text('Bằng mã OTP'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _loginMethod == 1 ? const Color(0xFF4A90E2) : Colors.grey,
                                  side: BorderSide(color: _loginMethod == 1 ? const Color(0xFF4A90E2) : Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Ô nhập Username / Email
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: _authMode == 0 ? 'Tên đăng nhập (Username)' : 'Nhập Email đăng ký',
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4A90E2)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chọn Role khi Đăng ký
                      if (_authMode == 1) ...[
                        DropdownButtonFormField<String>(
                          initialValue: _registerRole,
                          decoration: InputDecoration(
                            labelText: 'Đăng ký với vai trò',
                            prefixIcon: const Icon(Icons.badge, color: Color(0xFF4A90E2)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: const [
                            DropdownMenuItem(value: 'GiangVien', child: Text('Giảng viên / Nhân viên (Tạo QR điểm danh)')),
                            DropdownMenuItem(value: 'SinhVien', child: Text('Sinh viên (Quét QR điểm danh)')),
                            DropdownMenuItem(value: 'Admin', child: Text('Quản trị viên (Admin)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _registerRole = val);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Ô nhập Mật khẩu / OTP
                      if (_loginMethod == 0 || _authMode == 1)
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: _authMode == 0 ? 'Mật khẩu' : 'Mật khẩu mới',
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4A90E2)),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        )
                      else
                        TextField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: 'Nhập mã OTP từ Email',
                            prefixIcon: const Icon(Icons.security, color: Color(0xFF4A90E2)),
                            suffixIcon: TextButton(
                              onPressed: _handleSendOtp,
                              child: const Text(
                                'Gửi OTP',
                                style: TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold),
                              ),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Nút hành động chính
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            _authMode == 0
                                ? (_loginMethod == 0 ? 'Đăng nhập bằng Mật khẩu' : 'Xác thực mã OTP')
                                : 'Đăng ký tài khoản',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      if (_authMode == 0) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _handleBiometricLogin,
                          icon: const Icon(Icons.fingerprint, color: Color(0xFF4A90E2), size: 22),
                          label: const Text('Đăng nhập bằng Vân tay', style: TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4A90E2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}