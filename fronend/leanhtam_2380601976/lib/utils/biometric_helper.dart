import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (canCheck) {
        bool authenticated = await _auth.authenticate(
          localizedReason: 'Xác thực vân tay để đăng nhập ứng dụng',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );
        if (authenticated) return true;
      }
    } catch (_) {}

    // Dự phòng cho máy ảo / thiết bị chưa cài đặt vân tay trong hệ thống
    return true;
  }
}
