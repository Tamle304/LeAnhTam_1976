import 'package:flutter/material.dart';

class ClassDetailScreen extends StatelessWidget {
  final Map<String, dynamic> classData;

  const ClassDetailScreen({super.key, required this.classData});

  @override
  Widget build(BuildContext context) {
    final String className = (classData['Name'] ?? classData['name'] ?? classData['ClassName'] ?? classData['className'] ?? 'Lớp học').toString();
    final String classCode = (classData['Code'] ?? classData['code'] ?? classData['ClassCode'] ?? classData['classCode'] ?? 'N/A').toString();
    final String room = (classData['Room'] ?? classData['room'] ?? 'P.102 - Nhà A').toString();
    final String schedule = (classData['Schedule'] ?? classData['schedule'] ?? 'Thứ 2, 08:00 - 11:30').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin chi tiết lớp học
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Color(0xFFE8F1FF),
                          child: Icon(Icons.class_, color: Color(0xFF4A90E2), size: 30),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(className, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Mã lớp học phần: $classCode', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.meeting_room, color: Color(0xFF4A90E2)),
                      title: const Text('Phòng học', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(room),
                    ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time, color: Color(0xFF4A90E2)),
                      title: const Text('Lịch học hàng tuần', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(schedule),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Danh sách các buổi học / phiên điểm danh
            const Text('Các Buổi Học & Điểm Danh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildSessionCard(
              context,
              sessionName: 'Buổi 1: Tổng quan môn học & Môi trường Flutter',
              date: '2026-10-15 (08:00 - 11:30)',
              status: 'Đã hoàn thành',
              statusColor: Colors.green,
            ),
            const SizedBox(height: 10),
            _buildSessionCard(
              context,
              sessionName: 'Buổi 2: Xây dựng Giao diện & State Management',
              date: '2026-10-22 (08:00 - 11:30)',
              status: 'Đang diễn ra điểm danh',
              statusColor: Colors.orange,
              isCurrent: true,
            ),
            const SizedBox(height: 10),
            _buildSessionCard(
              context,
              sessionName: 'Buổi 3: Tích hợp API REST & Database',
              date: '2026-10-29 (08:00 - 11:30)',
              status: 'Sắp diễn ra',
              statusColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, {
    required String sessionName,
    required String date,
    required String status,
    required Color statusColor,
    bool isCurrent = false,
  }) {
    return Card(
      elevation: isCurrent ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent ? const BorderSide(color: Color(0xFF4A90E2), width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(isCurrent ? Icons.qr_code_scanner : Icons.event_note, color: statusColor, size: 28),
        title: Text(sessionName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('Thời gian: $date\nTrạng thái: $status', style: const TextStyle(fontSize: 12)),
        trailing: isCurrent
            ? ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng trở lại Màn hình chính và nhấn QUÉT QR ĐIỂM DANH!'),
                      backgroundColor: Color(0xFF4A90E2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
                child: const Text('Điểm danh', style: TextStyle(fontSize: 12)),
              )
            : OutlinedButton(
                onPressed: () {
                  _showLeaveDialog(context, sessionName);
                },
                child: const Text('Xin nghỉ', style: TextStyle(fontSize: 12)),
              ),
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, String sessionName) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi Đơn Xin Nghỉ Học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buổi học: $sessionName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do xin nghỉ phép...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã gửi đơn xin nghỉ phép thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Gửi Đơn'),
          ),
        ],
      ),
    );
  }
}
