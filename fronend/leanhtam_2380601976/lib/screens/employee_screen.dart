import 'package:flutter/material.dart';
import 'auth_screen.dart';
import '../services/api_service.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _classList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);
    var classes = await _apiService.getClasses();
    setState(() {
      _classList = classes;
      _isLoading = false;
    });
  }

  void _showQrDialog(BuildContext context, String className) {
    final TextEditingController sessionCodeController = TextEditingController(text: 'SESSION_1976');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tạo Mã QR Điểm Danh', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1B1B3A), width: 2),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2, size: 160, color: Color(0xFF1B1B3A)),
                      const SizedBox(height: 8),
                      Text('Mã QR phiên: ${sessionCodeController.text}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('Lớp: $className', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sessionCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Tùy chỉnh mã phiên QR',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sinh viên dùng ứng dụng di động để quét mã QR này điểm danh.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveRequestsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duyệt Đơn Xin Nghỉ Học'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildLeaveItem(context, name: 'Lê Anh Tâm', classCode: 'DPM1976', reason: 'Nghỉ ốm có giấy xác nhận y tế', date: '2026-10-22'),
              const Divider(),
              _buildLeaveItem(context, name: 'Nguyễn Văn B', classCode: 'WEB2024', reason: 'Bận việc gia đình đột xuất', date: '2026-10-21'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  Widget _buildLeaveItem(BuildContext context, {required String name, required String classCode, required String reason, required String date}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE8F1FF),
        child: Icon(Icons.person, color: Color(0xFF1B1B3A)),
      ),
      title: Text('$name ($classCode)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text('Lý do: $reason\nNgày: $date', style: const TextStyle(fontSize: 11)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã duyệt đơn xin nghỉ học của $name'), backgroundColor: Colors.green),
          );
        },
        child: const Text('Duyệt', style: TextStyle(fontSize: 11)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Trang Bảng Điều Khiển Giảng Viên', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B1B3A),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Thông tin Giảng viên
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF1B1B3A),
                    child: Icon(Icons.co_present, size: 35, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Xin chào Giảng viên!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Khoa Công nghệ Thông tin', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút Thao tác Nhanh
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQrDialog(context, 'Lập trình di động'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B1B3A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Tạo Mã QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showLeaveRequestsDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B1B3A),
                      side: const BorderSide(color: Color(0xFF1B1B3A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Duyệt Đơn Nghỉ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Danh sách các Lớp Giảng dạy
            const Text('Danh Sách Lớp Giảng Dạy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _classList.length,
              itemBuilder: (context, index) {
                final c = _classList[index];
                final String className = (c['Name'] ?? c['name'] ?? c['ClassName'] ?? c['className'] ?? 'Lớp học').toString();
                final String classCode = (c['Code'] ?? c['code'] ?? c['ClassCode'] ?? c['classCode'] ?? 'N/A').toString();
                final String room = (c['Room'] ?? c['room'] ?? 'P.102').toString();

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F1FF),
                      child: Icon(Icons.class_, color: Color(0xFF1B1B3A)),
                    ),
                    title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Mã LHP: $classCode | Phòng: $room', style: const TextStyle(fontSize: 12)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2), foregroundColor: Colors.white),
                      onPressed: () => _showQrDialog(context, className),
                      child: const Text('Mở Điểm Danh', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
