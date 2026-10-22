import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../class_detail_screen.dart';

class AdminClassesScreen extends StatefulWidget {
  const AdminClassesScreen({super.key});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _classList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    var classes = await _apiService.getClasses();
    setState(() {
      _classList = classes;
      _isLoading = false;
    });
  }

  void _showAddClassDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController roomController = TextEditingController();
    final TextEditingController scheduleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Lớp Học Phần Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên lớp / môn học', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Mã lớp học phần', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(labelText: 'Phòng học (VD: A101)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(labelText: 'Lịch học (VD: Thứ 2, 8:00)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final code = codeController.text.trim();
              if (name.isEmpty || code.isEmpty) return;

              setState(() {
                _classList.insert(0, {
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'name': name,
                  'code': code,
                  'className': name,
                  'classCode': code,
                  'room': roomController.text.trim().isEmpty ? 'P.101' : roomController.text.trim(),
                  'schedule': scheduleController.text.trim().isEmpty ? 'Thứ 2, 08:00' : scheduleController.text.trim(),
                });
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm lớp học phần mới thành công!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Thêm Mới'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Lớp Học Phần'),
        backgroundColor: const Color(0xFFD35400),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: _showAddClassDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD35400),
        onPressed: _showAddClassDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classList.isEmpty
          ? const Center(child: Text('Chưa có lớp học nào trong hệ thống'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _classList.length,
        itemBuilder: (context, index) {
          final c = _classList[index];
          final String className = (c['Name'] ?? c['name'] ?? c['ClassName'] ?? c['className'] ?? 'Lớp học').toString();
          final String classCode = (c['Code'] ?? c['code'] ?? c['ClassCode'] ?? c['classCode'] ?? 'N/A').toString();
          final String room = (c['Room'] ?? c['room'] ?? 'P.102').toString();
          final String schedule = (c['Schedule'] ?? c['schedule'] ?? 'Thứ 2, 08:00').toString();

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.class_, color: Color(0xFFD35400)),
              ),
              title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Text('Mã LHP: $classCode | Phòng: $room\nLịch học: $schedule', style: const TextStyle(fontSize: 12)),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassDetailScreen(classData: c)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
