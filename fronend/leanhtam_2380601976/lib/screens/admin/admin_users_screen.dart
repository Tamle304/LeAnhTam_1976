import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _usersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    var users = await _apiService.getUsers();
    setState(() {
      _usersList = users;
      _isLoading = false;
    });
  }

  void _showAddUserDialog() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    String selectedRole = 'SinhVien';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm Tài Khoản Mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Tên đăng nhập', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Phân quyền (Role)', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin (Quản trị)')),
                    DropdownMenuItem(value: 'GiangVien', child: Text('Giảng viên / Nhân viên')),
                    DropdownMenuItem(value: 'SinhVien', child: Text('Sinh viên / Khách hàng')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final uname = usernameController.text.trim();
                final email = emailController.text.trim();
                if (uname.isEmpty) return;

                setState(() {
                  _usersList.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'username': uname,
                    'email': email.isEmpty ? '$uname@st.vtc.edu.vn' : email,
                    'role': selectedRole,
                  });
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm tài khoản mới thành công!'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Thêm Mới'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(int index, Map<String, dynamic> user) {
    final String currentUsername = (user['username'] ?? user['Username'] ?? 'User').toString();
    final TextEditingController emailController = TextEditingController(text: (user['email'] ?? user['Email'] ?? '').toString());
    String selectedRole = (user['role'] ?? user['Role'] ?? 'SinhVien').toString();
    if (!['Admin', 'GiangVien', 'SinhVien'].contains(selectedRole)) {
      selectedRole = 'SinhVien';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Chỉnh Sửa: $currentUsername'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Phân quyền (Role)', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin (Quản trị)')),
                    DropdownMenuItem(value: 'GiangVien', child: Text('Giảng viên / Nhân viên')),
                    DropdownMenuItem(value: 'SinhVien', child: Text('Sinh viên / Khách hàng')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _usersList[index]['email'] = emailController.text.trim();
                  _usersList[index]['role'] = selectedRole;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật tài khoản thành công!'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Cập Nhật'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác Nhận Xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản này khỏi hệ thống?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _usersList.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa tài khoản khỏi cơ sở dữ liệu'), backgroundColor: Colors.redAccent),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Tài Khoản Hệ Thống'),
        backgroundColor: const Color(0xFFD35400),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD35400),
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usersList.isEmpty
          ? const Center(child: Text('Không có tài khoản nào trong cơ sở dữ liệu'))
          : ListView.builder(
        itemCount: _usersList.length,
        itemBuilder: (context, index) {
          final user = _usersList[index];
          final String username = (user['username'] ?? user['Username'] ?? user['fullName'] ?? user['FullName'] ?? 'Người dùng').toString();
          final String email = (user['email'] ?? user['Email'] ?? 'N/A').toString();
          final dynamic role = user['role'] ?? user['Role'] ?? 'SinhVien';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFD35400),
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Email: $email\nPhân quyền Role: $role'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () => _showEditUserDialog(index, user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _deleteUser(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
