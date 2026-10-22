import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _attendanceList = [];
  List<dynamic> _classList = [];
  List<dynamic> _usersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    var attendance = await _apiService.getAttendanceHistory();
    var classes = await _apiService.getClasses();
    var users = await _apiService.getUsers();

    setState(() {
      _attendanceList = attendance;
      _classList = classes;
      _usersList = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo Điểm Danh Toàn Trường'),
        backgroundColor: const Color(0xFFD35400),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thống kê tổng quan dạng Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Tổng Số Lớp',
                    value: _classList.length.toString(),
                    icon: Icons.class_,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Tài Khoản',
                    value: _usersList.length.toString(),
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Lượt Điểm Danh',
                    value: _attendanceList.length.toString(),
                    icon: Icons.check_circle,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Lịch Sử Điểm Danh Chi Tiết Toàn Trường',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _attendanceList.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text('Chưa có lịch sử điểm danh nào', style: TextStyle(color: Colors.grey)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _attendanceList.length,
              itemBuilder: (context, index) {
                final item = _attendanceList[index];
                final subject = (item['SubjectName'] ?? item['subjectName'] ?? item['CourseName'] ?? 'Môn học').toString();
                final time = (item['CreatedDate'] ?? item['createdDate'] ?? item['CheckInTime'] ?? 'N/A').toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.check, color: Colors.green),
                    ),
                    title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Thời gian ghi nhận: $time', style: const TextStyle(fontSize: 12)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Có mặt',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
