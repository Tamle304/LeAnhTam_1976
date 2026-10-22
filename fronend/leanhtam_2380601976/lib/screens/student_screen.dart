import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';
import 'class_detail_screen.dart';
import 'location_share_screen.dart';
import 'ocr_translate_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final ApiService _apiService = ApiService();
  String _locationMessage = "Đang xác thực vị trí GPS...";
  double? _lat;
  double? _lng;
  bool _isLoading = false;

  List<dynamic> _attendanceHistory = [];
  List<dynamic> _classList = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() => _isLoadingData = true);
    var history = await _apiService.getAttendanceHistory();
    var classes = await _apiService.getClasses();
    setState(() {
      _attendanceHistory = history;
      _classList = classes;
      _isLoadingData = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationMessage = 'GPS đang bị tắt trên thiết bị.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationMessage = 'Quyền truy cập vị trí bị từ chối.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _lat = position.latitude;
      _lng = position.longitude;
      _locationMessage = 'Đã sẵn sàng điểm danh!\nLat: $_lat, Lng: $_lng';
    });
  }

  void _openQrScanner() {
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đợi lấy tọa độ GPS!'), backgroundColor: Colors.orange),
      );
      return;
    }

    final TextEditingController manualQrController = TextEditingController(text: 'SESSION_1976');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Quét Mã QR Điểm Danh'),
            backgroundColor: const Color(0xFF4A90E2),
            foregroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    if (barcode.rawValue != null) {
                      String qrCode = barcode.rawValue!;
                      Navigator.pop(context);
                      _sendAttendanceData(qrCode);
                      break;
                    }
                  }
                },
              ),
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Đang mở Camera quét mã... Hoặc nhập thủ công bên dưới:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: manualQrController,
                              decoration: const InputDecoration(
                                hintText: 'Nhập nội dung QR (VD: SESSION_1976)',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              String code = manualQrController.text.trim();
                              if (code.isEmpty) return;
                              Navigator.pop(context);
                              _sendAttendanceData(code);
                            },
                            child: const Text('Gửi'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendAttendanceData(String qrCode) async {
    setState(() => _isLoading = true);
    var result = await _apiService.submitAttendance(qrCode, _lat!, _lng!);
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Điểm danh thành công!'),
        backgroundColor: result['status'] == true ? Colors.green : Colors.red,
      ),
    );

    if (result['status'] == true) {
      _loadStudentData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Điểm Danh Sinh Viên', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _getCurrentLocation();
          await _loadStudentData();
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.location_on, size: 35, color: Color(0xFF4A90E2)),
                    const SizedBox(height: 6),
                    Text(
                      _locationMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Làm mới GPS'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LocationShareScreen()),
                        );
                      },
                      icon: const Icon(Icons.share_location, size: 18),
                      label: const Text('Chia sẻ vị trí', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OCRTranslateScreen()),
                        );
                      },
                      icon: const Icon(Icons.g_translate, size: 18),
                      label: const Text('Dịch Realtime', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _openQrScanner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('QUÉT QR ĐIỂM DANH', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              const Text('Danh Sách Lớp Học', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: _isLoadingData
                    ? const Center(child: CircularProgressIndicator())
                    : _classList.isEmpty
                    ? const Center(child: Text('Chưa có lớp học nào trong hệ thống', style: TextStyle(color: Colors.grey, fontSize: 13)))
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _classList.length,
                  itemBuilder: (context, index) {
                    final c = _classList[index];
                    // Hỗ trợ bắt cả key viết hoa lẫn viết thường từ .NET/SQL
                    final className = c['Name'] ?? c['name'] ?? c['ClassName'] ?? c['className'] ?? 'Lớp học';
                    final classCode = c['Code'] ?? c['code'] ?? c['ClassCode'] ?? c['classCode'] ?? 'N/A';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ClassDetailScreen(classData: c)),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.class_, color: Color(0xFF4A90E2), size: 20),
                            const SizedBox(height: 4),
                            Text(className,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                            Text('Mã: $classCode',
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              const Text('Lịch Sử Điểm Danh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoadingData
                    ? const Center(child: CircularProgressIndicator())
                    : _attendanceHistory.isEmpty
                    ? const Center(child: Text('Chưa có dữ liệu điểm danh trong Database', style: TextStyle(color: Colors.grey, fontSize: 13)))
                    : ListView.builder(
                  itemCount: _attendanceHistory.length,
                  itemBuilder: (context, index) {
                    final item = _attendanceHistory[index];
                    // Hỗ trợ bắt cả key viết hoa lẫn viết thường cho lịch sử điểm danh
                    final subject = item['SubjectName'] ?? item['subjectName'] ?? item['CourseName'] ?? item['courseName'] ?? 'Môn học';
                    final time = item['CreatedDate'] ?? item['createdDate'] ?? item['CheckInTime'] ?? item['checkInTime'] ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(Icons.check, color: Colors.green, size: 20),
                        ),
                        title: Text(subject,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('Thời gian: $time',
                            style: const TextStyle(fontSize: 11)),
                        trailing: const Text('Thành công',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 11)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}