import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'admin_panel.dart';

class AdminLoginScreen extends StatefulWidget {
  final VoidCallback onProductUpdated;
  final VoidCallback onCategoryUpdated;
  const AdminLoginScreen({
    Key? key,
    required this.onProductUpdated,
    required this.onCategoryUpdated,
  }) : super(key: key);

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passwordController = TextEditingController();
  final _adminPassword = '123456'; // Gerçek uygulamada bu şifreyi güvenli bir şekilde saklayın
  bool _isPasswordVisible = false;
  String _errorMessage = '';

  void _login() {
    if (_passwordController.text == _adminPassword) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AdminPanelScreen(
            onProductUpdated: widget.onProductUpdated,
            onCategoryUpdated: widget.onCategoryUpdated,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Hatalı şifre!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Girişi'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_circle,
              size: 100,
              color: isDarkMode ? Colors.white : Colors.blue,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Admin Şifresi',
                hintText: 'Şifrenizi girin',
                prefixIcon: const Icon(CupertinoIcons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _login(),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
} 