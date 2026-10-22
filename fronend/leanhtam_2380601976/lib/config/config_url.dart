import 'package:flutter_dotenv/flutter_dotenv.dart';

// Class quản lý đường dẫn API theo chuẩn bài học
// ignore: camel_case_types
class ConfigURL {
  // Đường dẫn mặc định chuẩn có sẵn /api/
  static const String deployedServerUrl = 'http://157.10.201.16/api/';

  static String get baseUrl {
    if (dotenv.isInitialized) {
      final url = dotenv.env['BASE_URL']?.trim();
      if (url != null && url.isNotEmpty) {
        var cleaned = url;
        // Xóa các dấu / thừa ở cuối
        while (cleaned.endsWith('/')) {
          cleaned = cleaned.substring(0, cleaned.length - 1);
        }
        // Nếu chưa có /api ở cuối thì tự động thêm vào để không bị lỗi 404
        if (!cleaned.endsWith('/api')) {
          cleaned = '$cleaned/api';
        }
        // Trả về kèm dấu '/' ở cuối chuẩn chỉnh
        return '$cleaned/';
      }
    }
    return deployedServerUrl;
  }
}